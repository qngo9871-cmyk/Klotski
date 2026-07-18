import Foundation

enum BlockKind: String, Codable {
    case general   // 2x2 — Cao Cao
    case horizontal // 2x1
    case vertical   // 1x2
    case soldier    // 1x1

    var width: Int {
        switch self {
        case .general: return 2
        case .horizontal: return 2
        case .vertical: return 1
        case .soldier: return 1
        }
    }

    var height: Int {
        switch self {
        case .general: return 2
        case .horizontal: return 1
        case .vertical: return 2
        case .soldier: return 1
        }
    }
}

struct Block: Identifiable, Codable, Equatable {
    let id: Int
    let kind: BlockKind
    var col: Int
    var row: Int

    var width: Int { kind.width }
    var height: Int { kind.height }

    var cells: [(col: Int, row: Int)] {
        var out: [(Int, Int)] = []
        for dc in 0..<width {
            for dr in 0..<height {
                out.append((col + dc, row + dr))
            }
        }
        return out
    }

    static func == (lhs: Block, rhs: Block) -> Bool {
        lhs.id == rhs.id && lhs.col == rhs.col && lhs.row == rhs.row
    }
}

enum Direction: CaseIterable {
    case up, down, left, right

    var delta: (dc: Int, dr: Int) {
        switch self {
        case .up: return (0, -1)
        case .down: return (0, 1)
        case .left: return (-1, 0)
        case .right: return (1, 0)
        }
    }
}
