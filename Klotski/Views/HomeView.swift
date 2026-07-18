import SwiftUI

struct HomeView: View {
    @EnvironmentObject var loc: LocalizationManager
    @StateObject private var purchases = PurchaseManager.shared
    @State private var showGame = false
    @State private var showRules = false
    @State private var showUpgrade = false
    @State private var game: GameModel = GameModel(puzzle: PuzzleLibrary.puzzle(id: "classic")!)
    @State private var refreshToken = 0

    private func isLocked(_ puzzle: Puzzle) -> Bool {
        (puzzle.tier == .medium || puzzle.tier == .hard) && puzzle.id != "classic" && !purchases.isPro
    }

    private func tap(_ puzzle: Puzzle) {
        if isLocked(puzzle) {
            showUpgrade = true
        } else {
            game = GameModel(puzzle: puzzle)
            showGame = true
        }
    }

    private func section(_ title: String, tier: PuzzleTier) -> some View {
        Section(title) {
            ForEach(PuzzleLibrary.puzzles(tier: tier)) { puzzle in
                row(puzzle)
            }
        }
    }

    private func row(_ puzzle: Puzzle) -> some View {
        Button { tap(puzzle) } label: {
            HStack {
                Text(L(puzzle.nameKey)).foregroundStyle(.primary)
                Spacer()
                if let best = GameModel.bestScore(for: puzzle.id) {
                    Label(String(format: L("game.best"), best), systemImage: "checkmark.circle.fill")
                        .font(.caption).foregroundStyle(.green)
                } else if isLocked(puzzle) {
                    Label(L("home.locked"), systemImage: "lock.fill")
                        .font(.caption).foregroundStyle(.yellow)
                }
            }
        }
        .id(refreshToken)
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 6) {
                        AppEmblem(size: 48)
                        Text(L("home.title")).font(.system(size: 30, weight: .heavy, design: .rounded))
                        Text(L("home.subtitle")).font(.subheadline).foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .listRowBackground(Color.clear)
                }

                Section(L("home.tier.classic")) {
                    row(PuzzleLibrary.puzzle(id: "classic")!)
                }
                section(L("home.tier.easy"), tier: .easy)
                section(L("home.tier.medium"), tier: .medium)
                section(L("home.tier.hard"), tier: .hard)

                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(L("home.crosssell.title")).font(.footnote.bold())
                        Text(L("home.crosssell.body")).font(.caption).foregroundStyle(.secondary)
                        Link(destination: URL(string: "https://apps.apple.com/app/id\(AppLinks.chineseChessAppID)")!) {
                            Text(L("home.crosssell.cta")).font(.caption.bold())
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Button { showRules = true } label: {
                        Label(L("game.rules"), systemImage: "questionmark.circle")
                    }
                    if !purchases.isPro {
                        Button { showUpgrade = true } label: {
                            Label(L("upgrade.title"), systemImage: "star.fill").foregroundStyle(.yellow)
                        }
                    }
                }

                Section {
                    Picker("", selection: $loc.language) {
                        ForEach(AppLanguage.allCases) { lang in
                            Text(lang.displayName).tag(lang)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .listRowBackground(Color.clear)
            }
            .navigationDestination(isPresented: $showGame) {
                GameView(game: game)
                    .onDisappear { refreshToken += 1 }
            }
            .sheet(isPresented: $showRules) { RulesView() }
            .sheet(isPresented: $showUpgrade) { UpgradeView() }
            .task { await purchases.loadProduct() }
        }
    }
}

enum AppLinks {
    /// ChineseChess Pro Classic — same dev account, same Three Kingdoms theming.
    static let chineseChessAppID = "6762035708"
}

#Preview { HomeView().environmentObject(LocalizationManager.shared) }
