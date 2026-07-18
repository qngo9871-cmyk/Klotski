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
                    Text("🧩").font(.system(size: 50))
                    Text(L("upgrade.title")).font(.title.bold()).foregroundStyle(.white)
                    Text(L("upgrade.subtitle")).font(.subheadline).foregroundStyle(.white.opacity(0.75))
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
                            } else {
                                ProgressView().tint(.white)
                            }
                        }
                        .buttonStyle(.borderedProminent).tint(.red)
                        .disabled(purchases.isPurchasing || purchases.product == nil)

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

    private func featureRow(_ icon: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon).foregroundStyle(.red).frame(width: 24)
            Text(text).foregroundStyle(.white)
        }
    }
}

#Preview { UpgradeView() }
