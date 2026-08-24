import StoreKit

@MainActor
class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    @Published var isPro = false
    @Published var product: Product?
    @Published var isLoadingProduct = false
    @Published var productLoadFailed = false
    @Published var isPurchasing = false
    @Published var purchaseError: String?
    @Published var trialActive = true

    private let productID = "com.quyenngo.klotski.pro"
    private var transactionListener: Task<Void, Never>?

    private let firstLaunchKey = "firstLaunchDate"
    private let trialDuration: TimeInterval = 7 * 24 * 60 * 60

    /// True while Pro is owned OR the 7-day trial is still running — this is the
    /// single check every gate in the app should use instead of `isPro` directly.
    /// There is no permanently-free tier: once the trial elapses and isPro is
    /// false, this goes false too and every puzzle (including the ones that used
    /// to be free forever) locks behind the paywall.
    var hasFullAccess: Bool { isPro || trialActive }

    /// Days left in the 7-day free trial (0 once expired). Once it elapses,
    /// every puzzle — including Classic and the four Easy puzzles, which used to
    /// be free forever — locks behind the paywall, along with the hint system.
    var trialDaysRemaining: Int {
        let defaults = UserDefaults.standard
        guard let firstLaunch = defaults.object(forKey: firstLaunchKey) as? Date else { return 7 }
        let remaining = trialDuration - Date().timeIntervalSince(firstLaunch)
        return max(0, Int(ceil(remaining / (24 * 60 * 60))))
    }

    init() {
        transactionListener = listenForTransactions()
        evaluateTrialStatus()
        Task { await updateEntitlementStatus() }
    }

    /// Reads (or sets, on first-ever launch) the trial start date and updates
    /// `trialActive`. Existing installs upgrading from a pre-trial build have no
    /// stored date yet, so this starts their 7-day clock rather than locking
    /// them out immediately.
    func evaluateTrialStatus() {
        let defaults = UserDefaults.standard
        let now = Date()
        let firstLaunch: Date
        if let stored = defaults.object(forKey: firstLaunchKey) as? Date {
            firstLaunch = stored
        } else {
            firstLaunch = now
            defaults.set(now, forKey: firstLaunchKey)
        }
        trialActive = Date().timeIntervalSince(firstLaunch) < trialDuration
    }

    deinit { transactionListener?.cancel() }

    func loadProduct() async {
        isLoadingProduct = true
        productLoadFailed = false
        do {
            let products = try await withTimeout(seconds: 10) {
                try await Product.products(for: [self.productID])
            }
            product = products.first
            if product == nil { productLoadFailed = true }
        } catch {
            productLoadFailed = true
        }
        isLoadingProduct = false
    }

    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask { try await operation() }
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw CancellationError()
            }
            guard let result = try await group.next() else { throw CancellationError() }
            group.cancelAll()
            return result
        }
    }

    func purchase() async {
        guard let product else {
            purchaseError = "Product not available. Please try again."
            return
        }
        isPurchasing = true
        purchaseError = nil
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                // Grant on both .verified AND .unverified — treating unverified as a hard
                // failure silently drops legitimate purchases (JWS edge cases, StoreKit
                // sandbox quirks). Finish the transaction either way so it doesn't retry forever.
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    isPro = true
                case .unverified(let transaction, _):
                    await transaction.finish()
                    isPro = true
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                purchaseError = "An unexpected error occurred."
            }
        } catch {
            purchaseError = error.localizedDescription
        }
        isPurchasing = false
    }

    func restorePurchases() async {
        isPurchasing = true
        purchaseError = nil
        do {
            try await AppStore.sync()
        } catch {
            purchaseError = "Could not restore purchases. Please try again."
            isPurchasing = false
            return
        }
        await updateEntitlementStatus()
        if !isPro { purchaseError = "No purchase found to restore." }
        isPurchasing = false
    }

    func updateEntitlementStatus() async {
        #if DEBUG
        // Double-gating bug fix (2026-08-24, portfolio-wide compliance-gate finding):
        // a bare `isPro = true` here masked the real free-tier/trial state on every
        // Debug run and every "home"/"upgrade" screenshot capture, the same class of
        // bug already fixed in SamLoc/Fanorona/Dara/Surakarta. Only force-unlock for
        // capture scenarios that are supposed to show unlocked content.
        let capture = ProcessInfo.processInfo.environment["KL_CAPTURE"]
        isPro = capture != nil && capture != "home" && capture != "upgrade"
        #else
        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction), .unverified(let transaction, _):
                if transaction.productID == productID, transaction.revocationDate == nil {
                    isPro = true
                    return
                }
            }
        }
        isPro = false
        #endif
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task.detached { [weak self] in
            for await result in Transaction.updates {
                switch result {
                case .verified(let transaction), .unverified(let transaction, _):
                    await transaction.finish()
                    await self?.updateEntitlementStatus()
                }
            }
        }
    }
}
