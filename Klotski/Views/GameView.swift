import SwiftUI

struct GameView: View {
    @ObservedObject var game: GameModel
    @EnvironmentObject var loc: LocalizationManager
    @Environment(\.dismiss) var dismiss
    // Must be @ObservedObject, not a bare PurchaseManager.shared reference — the
    // isPro flip happens asynchronously after first render (entitlement check in
    // PurchaseManager.init()), and a non-observed read never triggers a re-render,
    // so the Hint button would show "locked" forever even once isPro becomes true.
    // Caught by visually inspecting a screenshot, not by the build succeeding.
    @ObservedObject private var purchases = PurchaseManager.shared

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.06, green: 0.06, blue: 0.08), .black],
                            startPoint: .top, endPoint: .bottom).ignoresSafeArea()

            VStack(spacing: 16) {
                header

                boardArea
                    .padding(.horizontal)

                Text(L("game.selectBlock"))
                    .font(.caption).foregroundStyle(.white.opacity(0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                if let bid = game.selectedBlockID {
                    directionalPad(blockID: bid)
                }

                Spacer()

                controls
            }
            .padding(.top, 8)
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(L(game.puzzle.nameKey)).font(.headline).foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $game.showWinSheet) {
            WinSheet(game: game)
        }
    }

    private var header: some View {
        HStack {
            Text(String(format: L("game.moves"), game.moveCount))
            Spacer()
            Text(String(format: L("game.par"), game.puzzle.minMoves))
            Spacer()
            if let best = game.bestScore {
                Text(String(format: L("game.best"), best))
            }
        }
        .font(.footnote.monospacedDigit())
        .foregroundStyle(.white.opacity(0.8))
        .padding(.horizontal)
    }

    private var boardArea: some View {
        GeometryReader { geo in
            let cellSize = min(geo.size.width / CGFloat(Board.width), geo.size.height / CGFloat(Board.height))
            let boardWidth = cellSize * CGFloat(Board.width)
            let boardHeight = cellSize * CGFloat(Board.height)
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.white.opacity(0.05))
                    .frame(width: boardWidth, height: boardHeight)
                exitMarker(cellSize: cellSize)
                ForEach(game.board.blocks) { block in
                    BlockView(
                        block: block,
                        cellSize: cellSize,
                        isSelected: game.selectedBlockID == block.id,
                        isHinted: game.hintBlockID == block.id
                    )
                    .onTapGesture { game.select(blockID: block.id) }
                }
            }
            .frame(width: boardWidth, height: boardHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .aspectRatio(CGFloat(Board.width) / CGFloat(Board.height), contentMode: .fit)
    }

    private func exitMarker(cellSize: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .strokeBorder(Color.green.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [5, 4]))
            .frame(width: cellSize * 2 - 4, height: cellSize * 2 - 4)
            .position(
                x: CGFloat(Board.exitCol) * cellSize + cellSize,
                y: CGFloat(Board.exitRow) * cellSize + cellSize
            )
    }

    private func directionalPad(blockID: Int) -> some View {
        VStack(spacing: 6) {
            dirButton(.up, blockID: blockID)
            HStack(spacing: 6) {
                dirButton(.left, blockID: blockID)
                Color.clear.frame(width: 44, height: 44)
                dirButton(.right, blockID: blockID)
            }
            dirButton(.down, blockID: blockID)
        }
    }

    private func dirButton(_ direction: Direction, blockID: Int) -> some View {
        let enabled = game.board.canMove(blockID: blockID, direction: direction)
        let isHintDir = game.hintBlockID == blockID && game.hintDirection == direction
        let icon: String = {
            switch direction {
            case .up: return "arrow.up"
            case .down: return "arrow.down"
            case .left: return "arrow.left"
            case .right: return "arrow.right"
            }
        }()
        return Button {
            game.move(blockID: blockID, direction: direction)
        } label: {
            Image(systemName: icon)
                .font(.title2.bold())
                .frame(width: 44, height: 44)
                .background(isHintDir ? Color.green.opacity(0.4) : Color.white.opacity(0.12))
                .foregroundStyle(enabled ? .white : .white.opacity(0.25))
                .clipShape(RoundedRectangle(cornerRadius: 10))
        }
        .disabled(!enabled)
    }

    private var controls: some View {
        HStack(spacing: 28) {
            Button { game.undo() } label: {
                VStack { Image(systemName: "arrow.uturn.backward"); Text(L("game.undo")).font(.caption2) }
            }
            .disabled(!game.canUndo)

            Button { game.restart() } label: {
                VStack { Image(systemName: "arrow.counterclockwise"); Text(L("game.restart")).font(.caption2) }
            }

            Button {
                if purchases.isPro {
                    game.requestHint()
                } else {
                    game.showWinSheet = false
                    hintLocked = true
                }
            } label: {
                VStack {
                    if game.isComputingHint {
                        ProgressView().tint(.white)
                    } else {
                        Image(systemName: purchases.isPro ? "lightbulb.fill" : "lock.fill")
                    }
                    Text(L("game.hint")).font(.caption2)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.bottom, 20)
        .sheet(isPresented: $hintLocked) { UpgradeView() }
    }

    @State private var hintLocked = false
}

struct WinSheet: View {
    @ObservedObject var game: GameModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 18) {
            Text("🎉").font(.system(size: 56))
            Text(L("win.title")).font(.title.bold())
            Text(String(format: L("win.moves"), game.moveCount))
            Text(String(format: L("win.par"), game.puzzle.minMoves)).foregroundStyle(.secondary)
            if let best = game.bestScore, best == game.moveCount {
                Text(L("win.newBest")).foregroundStyle(.green).font(.subheadline.bold())
            }
            Button { dismiss() } label: {
                Text(L("win.close")).frame(maxWidth: 240).padding()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .presentationDetents([.medium])
    }
}
