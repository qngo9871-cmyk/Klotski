import SwiftUI

struct RulesView: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    section(titleKey: "rules.goal.title", bodyKey: "rules.goal.body")
                    section(titleKey: "rules.moves.title", bodyKey: "rules.moves.body")
                    section(titleKey: "rules.hint.title", bodyKey: "rules.hint.body")
                }
                .padding()
            }
            .navigationTitle(L("rules.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("win.close")) { dismiss() }
                }
            }
        }
    }

    private func section(titleKey: String, bodyKey: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(L(titleKey)).font(.headline)
            Text(L(bodyKey)).font(.body).foregroundStyle(.secondary)
        }
    }
}

#Preview { RulesView() }
