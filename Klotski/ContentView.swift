import SwiftUI

struct ContentView: View {
    var body: some View {
        #if DEBUG
        if let lang = ProcessInfo.processInfo.environment["KL_LANG"], let l = AppLanguage(rawValue: lang) {
            LocalizationManager.shared.setLanguage(l)
        }
        if let capture = ProcessInfo.processInfo.environment["KL_CAPTURE"], capture != "home" {
            if capture == "upgrade" {
                return AnyView(UpgradeView().preferredColorScheme(.dark))
            }
            if capture == "rules" {
                return AnyView(RulesView().preferredColorScheme(.dark))
            }
            let puzzleID = capture == "win" ? "easy1" : "classic"
            let game = GameModel(puzzle: PuzzleLibrary.puzzle(id: puzzleID)!)
            if capture == "midgame" {
                _ = game.move(blockID: 6, direction: .down)
                _ = game.move(blockID: 7, direction: .down)
            } else if capture == "win" {
                // easy1 solves in 4 moves — walk it to the win sheet for a real capture.
                let solution = Solver.solve(from: game.board) ?? []
                for m in solution { _ = game.move(blockID: m.blockID, direction: m.direction) }
            }
            return AnyView(NavigationStack { GameView(game: game) }.preferredColorScheme(.dark))
        }
        #endif
        return AnyView(HomeView())
    }
}

#Preview { ContentView() }
