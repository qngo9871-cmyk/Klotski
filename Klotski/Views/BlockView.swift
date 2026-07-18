import SwiftUI

struct BlockView: View {
    let block: Block
    let cellSize: CGFloat
    let isSelected: Bool
    let isHinted: Bool

    private var color: Color {
        switch block.kind {
        case .general: return Color(red: 0.75, green: 0.12, blue: 0.12)
        case .horizontal, .vertical: return Color(red: 0.16, green: 0.35, blue: 0.55)
        case .soldier: return Color(red: 0.30, green: 0.30, blue: 0.32)
        }
    }

    private var label: String {
        switch block.kind {
        case .general: return "帥"
        case .horizontal, .vertical: return "將"
        case .soldier: return "卒"
        }
    }

    var body: some View {
        let w = CGFloat(block.width) * cellSize
        let h = CGFloat(block.height) * cellSize
        RoundedRectangle(cornerRadius: 10)
            .fill(color.gradient)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .strokeBorder(isSelected ? Color.yellow : (isHinted ? Color.green : Color.white.opacity(0.25)),
                                  lineWidth: isSelected || isHinted ? 3 : 1)
            )
            .overlay(
                Text(label)
                    .font(.system(size: min(w, h) * 0.4, weight: .heavy))
                    .foregroundStyle(.white.opacity(0.9))
            )
            .frame(width: w - 4, height: h - 4)
            .shadow(color: .black.opacity(0.4), radius: 3, y: 2)
            .position(
                x: CGFloat(block.col) * cellSize + w / 2,
                y: CGFloat(block.row) * cellSize + h / 2
            )
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: block.col)
            .animation(.spring(response: 0.25, dampingFraction: 0.8), value: block.row)
    }
}
