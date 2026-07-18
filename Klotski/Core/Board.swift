import Foundation

struct Board: Equatable {
    static let width = 4
    static let height = 5
    /// Exit gap for the general block — bottom-center, cols 1-2, rows 3-4.
    static let exitCol = 1
    static let exitRow = 3

    var blocks: [Block]

    init(blocks: [Block]) {
        self.blocks = blocks
    }

    var generalBlock: Block {
        blocks.first(where: { $0.kind == .general })!
    }

    var isSolved: Bool {
        let g = generalBlock
        return g.col == Self.exitCol && g.row == Self.exitRow
    }

    /// Canonical state key for the BFS visited-set — by (kind, position), NOT block id.
    /// The four soldiers and four vertical blocks are interchangeable; keying by id
    /// treats every relabeling as a distinct state (up to a 24×24 symmetry factor),
    /// which explodes the search space from ~26k true board configurations into the
    /// millions and makes BFS never converge. Confirmed via a Python prototype of this
    /// exact bug before writing this fix.
    var stateKey: String {
        blocks.sorted(by: { ($0.kind.rawValue, $0.col, $0.row) < ($1.kind.rawValue, $1.col, $1.row) })
            .map { "\($0.kind.rawValue):\($0.col),\($0.row)" }.joined(separator: "|")
    }

    private func occupancyGrid() -> [[Int?]] {
        var grid = Array(repeating: Array<Int?>(repeating: nil, count: Self.width), count: Self.height)
        for b in blocks {
            for c in b.cells {
                grid[c.row][c.col] = b.id
            }
        }
        return grid
    }

    func canMove(blockID: Int, direction: Direction) -> Bool {
        guard let block = blocks.first(where: { $0.id == blockID }) else { return false }
        let (dc, dr) = direction.delta
        let grid = occupancyGrid()
        for cell in block.cells {
            let nc = cell.col + dc
            let nr = cell.row + dr
            if nc < 0 || nc >= Self.width || nr < 0 || nr >= Self.height { return false }
            let occupant = grid[nr][nc]
            if let occupant, occupant != blockID { return false }
        }
        return true
    }

    mutating func move(blockID: Int, direction: Direction) -> Bool {
        guard canMove(blockID: blockID, direction: direction) else { return false }
        let (dc, dr) = direction.delta
        guard let idx = blocks.firstIndex(where: { $0.id == blockID }) else { return false }
        blocks[idx].col += dc
        blocks[idx].row += dr
        return true
    }

    /// All (blockID, direction) legal moves from the current state.
    func legalMoves() -> [(blockID: Int, direction: Direction)] {
        var moves: [(Int, Direction)] = []
        for b in blocks {
            for d in Direction.allCases {
                if canMove(blockID: b.id, direction: d) {
                    moves.append((b.id, d))
                }
            }
        }
        return moves
    }
}
