import Foundation

enum PuzzleTier: String, Codable, CaseIterable {
    case easy, medium, hard
}

struct Puzzle: Identifiable {
    let id: String
    let nameKey: String
    let tier: PuzzleTier
    /// Verified via exhaustive BFS at content-authoring time — see the generator
    /// script referenced in CLAUDE.md. Every puzzle below is solvable; this is the
    /// true shortest-path move count, shown as the "par" score in the UI.
    let minMoves: Int
    let blocks: [Int: (Int, Int)]

    func makeBoard() -> Board {
        let kinds: [Int: BlockKind] = [
            0: .general, 1: .horizontal,
            2: .vertical, 3: .vertical, 4: .vertical, 5: .vertical,
            6: .soldier, 7: .soldier, 8: .soldier, 9: .soldier,
        ]
        let blockList = (0..<10).map { id -> Block in
            let (col, row) = blocks[id]!
            return Block(id: id, kind: kinds[id]!, col: col, row: row)
        }
        return Board(blocks: blockList)
    }
}

enum PuzzleLibrary {
    // === PUZZLE DATA (verified solvable via BFS, see /gen_klotski_puzzles.py) ===
    static let all: [Puzzle] = [
        Puzzle(id: "classic", nameKey: "puzzle.classic.name", tier: .hard, minMoves: 87, blocks: [
            0: (0, 0), 1: (1, 2), 2: (2, 0), 3: (3, 0), 4: (0, 2), 5: (3, 2), 6: (1, 3), 7: (2, 3), 8: (0, 4), 9: (3, 4)
        ]),
        Puzzle(id: "easy1", nameKey: "puzzle.easy1.name", tier: .easy, minMoves: 4, blocks: [
            0: (2, 3), 1: (0, 3), 2: (3, 0), 3: (0, 0), 4: (1, 0), 5: (2, 0), 6: (1, 4), 7: (3, 2), 8: (0, 4), 9: (2, 2)
        ]),
        Puzzle(id: "easy2", nameKey: "puzzle.easy2.name", tier: .easy, minMoves: 13, blocks: [
            0: (2, 2), 1: (0, 3), 2: (3, 0), 3: (0, 0), 4: (1, 0), 5: (2, 0), 6: (3, 4), 7: (1, 2), 8: (2, 4), 9: (0, 2)
        ]),
        Puzzle(id: "easy3", nameKey: "puzzle.easy3.name", tier: .easy, minMoves: 5, blocks: [
            0: (2, 3), 1: (0, 3), 2: (2, 0), 3: (3, 0), 4: (1, 0), 5: (0, 0), 6: (3, 2), 7: (1, 4), 8: (0, 4), 9: (1, 2)
        ]),
        Puzzle(id: "easy4", nameKey: "puzzle.easy4.name", tier: .easy, minMoves: 14, blocks: [
            0: (2, 2), 1: (0, 4), 2: (2, 0), 3: (3, 0), 4: (1, 0), 5: (0, 0), 6: (1, 2), 7: (3, 4), 8: (2, 4), 9: (0, 2)
        ]),
        Puzzle(id: "medium1", nameKey: "puzzle.medium1.name", tier: .medium, minMoves: 30, blocks: [
            0: (0, 2), 1: (0, 4), 2: (3, 2), 3: (2, 0), 4: (2, 2), 5: (3, 0), 6: (3, 4), 7: (0, 1), 8: (2, 4), 9: (0, 0)
        ]),
        Puzzle(id: "medium2", nameKey: "puzzle.medium2.name", tier: .medium, minMoves: 48, blocks: [
            0: (0, 0), 1: (0, 2), 2: (3, 3), 3: (2, 1), 4: (2, 3), 5: (3, 1), 6: (1, 4), 7: (3, 0), 8: (0, 4), 9: (2, 0)
        ]),
        Puzzle(id: "medium3", nameKey: "puzzle.medium3.name", tier: .medium, minMoves: 31, blocks: [
            0: (0, 2), 1: (0, 4), 2: (3, 2), 3: (2, 0), 4: (2, 2), 5: (3, 0), 6: (3, 4), 7: (1, 1), 8: (2, 4), 9: (0, 0)
        ]),
        Puzzle(id: "medium4", nameKey: "puzzle.medium4.name", tier: .medium, minMoves: 33, blocks: [
            0: (0, 1), 1: (0, 4), 2: (3, 0), 3: (3, 2), 4: (2, 2), 5: (2, 0), 6: (1, 0), 7: (3, 4), 8: (2, 4), 9: (0, 0)
        ]),
        Puzzle(id: "medium5", nameKey: "puzzle.medium5.name", tier: .medium, minMoves: 51, blocks: [
            0: (0, 0), 1: (0, 2), 2: (3, 1), 3: (3, 3), 4: (1, 3), 5: (2, 1), 6: (3, 0), 7: (0, 4), 8: (0, 3), 9: (2, 0)
        ]),
        Puzzle(id: "medium6", nameKey: "puzzle.medium6.name", tier: .medium, minMoves: 47, blocks: [
            0: (0, 0), 1: (0, 3), 2: (3, 3), 3: (2, 1), 4: (2, 3), 5: (3, 1), 6: (1, 4), 7: (3, 0), 8: (0, 4), 9: (2, 0)
        ]),
        Puzzle(id: "medium7", nameKey: "puzzle.medium7.name", tier: .medium, minMoves: 31, blocks: [
            0: (0, 2), 1: (0, 4), 2: (3, 2), 3: (2, 0), 4: (2, 2), 5: (3, 0), 6: (0, 1), 7: (1, 0), 8: (3, 4), 9: (2, 4)
        ]),
        Puzzle(id: "hard1", nameKey: "puzzle.hard1.name", tier: .hard, minMoves: 65, blocks: [
            0: (0, 0), 1: (0, 2), 2: (2, 3), 3: (2, 1), 4: (1, 3), 5: (3, 1), 6: (0, 4), 7: (3, 0), 8: (0, 3), 9: (3, 4)
        ]),
        Puzzle(id: "hard2", nameKey: "puzzle.hard2.name", tier: .hard, minMoves: 78, blocks: [
            0: (0, 0), 1: (1, 2), 2: (2, 0), 3: (3, 0), 4: (1, 3), 5: (3, 3), 6: (0, 4), 7: (2, 3), 8: (0, 3), 9: (2, 4)
        ]),
        Puzzle(id: "hard3", nameKey: "puzzle.hard3.name", tier: .hard, minMoves: 66, blocks: [
            0: (0, 0), 1: (0, 2), 2: (2, 3), 3: (2, 0), 4: (1, 3), 5: (3, 1), 6: (0, 4), 7: (3, 0), 8: (0, 3), 9: (3, 4)
        ]),
        Puzzle(id: "hard4", nameKey: "puzzle.hard4.name", tier: .hard, minMoves: 79, blocks: [
            0: (0, 0), 1: (2, 2), 2: (2, 0), 3: (3, 0), 4: (1, 3), 5: (3, 3), 6: (0, 4), 7: (2, 3), 8: (0, 3), 9: (2, 4)
        ]),
        Puzzle(id: "hard5", nameKey: "puzzle.hard5.name", tier: .hard, minMoves: 70, blocks: [
            0: (0, 0), 1: (0, 2), 2: (3, 2), 3: (2, 2), 4: (1, 3), 5: (2, 0), 6: (3, 1), 7: (0, 4), 8: (0, 3), 9: (2, 4)
        ]),
        Puzzle(id: "hard6", nameKey: "puzzle.hard6.name", tier: .hard, minMoves: 84, blocks: [
            0: (0, 0), 1: (1, 2), 2: (3, 3), 3: (2, 0), 4: (0, 2), 5: (3, 0), 6: (2, 3), 7: (1, 4), 8: (0, 4), 9: (2, 4)
        ]),
        Puzzle(id: "hard7", nameKey: "puzzle.hard7.name", tier: .hard, minMoves: 64, blocks: [
            0: (0, 0), 1: (0, 2), 2: (2, 3), 3: (2, 1), 4: (1, 3), 5: (3, 1), 6: (0, 4), 7: (2, 0), 8: (0, 3), 9: (3, 4)
        ]),
    ]

    static func puzzle(id: String) -> Puzzle? {
        all.first(where: { $0.id == id })
    }

    static func puzzles(tier: PuzzleTier) -> [Puzzle] {
        all.filter { $0.tier == tier }
    }
}
