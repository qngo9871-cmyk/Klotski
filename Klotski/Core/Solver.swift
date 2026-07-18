import Foundation

/// Breadth-first search over the block-sliding state graph. State space for the
/// classic 4x5 Klotski board is bounded in the tens of thousands of reachable
/// configurations, so exhaustive BFS finds an optimal (shortest-move) solution
/// well under a second on-device — safe to call synchronously off the main thread.
enum Solver {
    struct Move: Equatable {
        let blockID: Int
        let direction: Direction
    }

    /// Returns the shortest sequence of moves to solve `board`, or nil if unsolvable
    /// (should never happen for a validated puzzle) or the node cap is exceeded.
    static func solve(from board: Board, nodeCap: Int = 300_000) -> [Move]? {
        if board.isSolved { return [] }

        var visited: Set<String> = [board.stateKey]
        var queue: [(board: Board, path: [Move])] = [(board, [])]
        var head = 0
        var explored = 0

        while head < queue.count {
            let current = queue[head]
            head += 1
            explored += 1
            if explored > nodeCap { return nil }

            for m in current.board.legalMoves() {
                var next = current.board
                _ = next.move(blockID: m.blockID, direction: m.direction)
                let key = next.stateKey
                if visited.contains(key) { continue }
                visited.insert(key)
                let path = current.path + [Move(blockID: m.blockID, direction: m.direction)]
                if next.isSolved { return path }
                queue.append((next, path))
            }
        }
        return nil
    }

    /// Just the next single move toward a solution — used for the in-app hint button.
    static func hint(from board: Board) -> Move? {
        solve(from: board)?.first
    }

    static func isSolvable(_ board: Board) -> Bool {
        solve(from: board) != nil
    }
}
