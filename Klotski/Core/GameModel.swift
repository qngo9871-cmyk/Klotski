import Foundation
import SwiftUI

@MainActor
final class GameModel: ObservableObject {
    @Published var board: Board
    @Published var selectedBlockID: Int?
    @Published var moveCount = 0
    @Published var isSolved = false
    @Published var hintBlockID: Int?
    @Published var hintDirection: Direction?
    @Published var isComputingHint = false
    @Published var showWinSheet = false

    private(set) var puzzle: Puzzle
    private var history: [Board] = []

    init(puzzle: Puzzle) {
        self.puzzle = puzzle
        self.board = puzzle.makeBoard()
    }

    func loadPuzzle(_ puzzle: Puzzle) {
        self.puzzle = puzzle
        board = puzzle.makeBoard()
        selectedBlockID = nil
        moveCount = 0
        isSolved = false
        hintBlockID = nil
        hintDirection = nil
        showWinSheet = false
        history = []
    }

    func restart() {
        loadPuzzle(puzzle)
    }

    func select(blockID: Int) {
        hintBlockID = nil
        hintDirection = nil
        selectedBlockID = (selectedBlockID == blockID) ? nil : blockID
    }

    @discardableResult
    func move(direction: Direction) -> Bool {
        guard let bid = selectedBlockID else { return false }
        return move(blockID: bid, direction: direction)
    }

    @discardableResult
    func move(blockID: Int, direction: Direction) -> Bool {
        guard board.canMove(blockID: blockID, direction: direction) else { return false }
        history.append(board)
        _ = board.move(blockID: blockID, direction: direction)
        moveCount += 1
        hintBlockID = nil
        hintDirection = nil
        if board.isSolved {
            isSolved = true
            recordBestScore()
            showWinSheet = true
        }
        return true
    }

    var canUndo: Bool { !history.isEmpty }

    func undo() {
        guard let last = history.popLast() else { return }
        board = last
        moveCount = max(0, moveCount - 1)
        selectedBlockID = nil
        hintBlockID = nil
        hintDirection = nil
    }

    /// Runs the BFS solver off the main thread — cheap for this board (well under a
    /// second) but still real work, don't block the UI while it runs.
    func requestHint() {
        guard !isComputingHint else { return }
        isComputingHint = true
        let currentBoard = board
        Task {
            let hint = await Task.detached { Solver.hint(from: currentBoard) }.value
            isComputingHint = false
            hintBlockID = hint?.blockID
            hintDirection = hint?.direction
            selectedBlockID = hint?.blockID
        }
    }

    // MARK: - Best score (UserDefaults)

    private var bestScoreKey: String { "best_moves_\(puzzle.id)" }

    var bestScore: Int? {
        let v = UserDefaults.standard.integer(forKey: bestScoreKey)
        return v > 0 ? v : nil
    }

    private func recordBestScore() {
        if let best = bestScore {
            if moveCount < best {
                UserDefaults.standard.set(moveCount, forKey: bestScoreKey)
            }
        } else {
            UserDefaults.standard.set(moveCount, forKey: bestScoreKey)
        }
    }

    static func bestScore(for puzzleID: String) -> Int? {
        let v = UserDefaults.standard.integer(forKey: "best_moves_\(puzzleID)")
        return v > 0 ? v : nil
    }

    static func isCompleted(_ puzzleID: String) -> Bool {
        bestScore(for: puzzleID) != nil
    }
}
