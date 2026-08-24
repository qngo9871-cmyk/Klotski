import SwiftUI

struct UpgradeView: View {
    @StateObject private var purchases = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.15, green: 0.05, blue: 0.05), .black],
                                startPoint: .top, endPoint: .bottom).ignoresSafeArea()
                VStack(spacing: 22) {
                    AppEmblem(size: 50)
                    Text(L("upgrade.title")).font(.title.bold()).foregroundStyle(.white)
                    Text(purchases.trialActive ? L("upgrade.subtitle") : L("upgrade.subtitle.trialEnded"))
                        .font(.subheadline).foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center).padding(.horizontal, 30)

                    VStack(alignment: .leading, spacing: 12) {
                        featureRow("square.grid.3x3.fill", L("upgrade.feature1"))
                        featureRow("lightbulb.fill", L("upgrade.feature2"))
                        featureRow("nosign", L("upgrade.feature3"))
                    }
                    .padding(.horizontal, 30)

                    if purchases.isPro {
                        Text(L("upgrade.owned")).foregroundStyle(.green).font(.headline)
                    } else {
                        Button {
                            Task { await purchases.purchase() }
                        } label: {
                            if purchases.isPurchasing {
                                ProgressView().tint(.white)
                            } else if let product = purchases.product {
                                Text(String(format: L("upgrade.buy"), product.displayPrice))
                                    .font(.title3.bold()).frame(maxWidth: 260).padding()
                            } else if isCaptureScreenshotFallback {
                                // App Store screenshot capture only: local StoreKit testing
                                // consistently fails to load a real Product via a bare
                                // `simctl launch` (no Xcode test host attached) — same known
                                // limitation as Janggi/Dara/Makruk/OAnQuan. Unlike those
                                // apps this view had no fallback UI at all when `product`
                                // stays nil, so the paywall screenshot was stuck on a
                                // permanent spinner regardless of wait time (found via
                                // vision QA, 2026-08-24). Renders the real, shipping button
                                // copy/price instead — never shown to a real user, gated on
                                // both #if DEBUG and the KL_CAPTURE screenshot launch arg.
                                Text(String(format: L("upgrade.buy"), "$2.99"))
                                    .font(.title3.bold()).frame(maxWidth: 260).padding()
                            } else {
                                ProgressView().tint(.white)
                            }
                        }
                        .buttonStyle(.borderedProminent).tint(.red)
                        .disabled(purchases.isPurchasing || (purchases.product == nil && !isCaptureScreenshotFallback))

                        Button(L("upgrade.restore")) { Task { await purchases.restorePurchases() } }
                            .font(.footnote).foregroundStyle(.white.opacity(0.6))

                        if let err = purchases.purchaseError {
                            Text(err).font(.caption).foregroundStyle(.red)
                        }
                    }

                    Button(L("upgrade.notnow")) { dismiss() }
                        .foregroundStyle(.white.opacity(0.5)).padding(.top, 6)
                }
                .padding()
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }

    private var isCaptureScreenshotFallback: Bool {
        #if DEBUG
        ProcessInfo.processInfo.environment["KL_CAPTURE"] == "upgrade"
        #else
        false
        #endif
    }

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(.red).frame(width: 24)
            Text(text).foregroundStyle(.white)
        }
    }
}

#Preview { UpgradeView() }
