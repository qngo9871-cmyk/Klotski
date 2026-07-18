import SwiftUI

/// Matches the actual app icon (red block, white "帥") instead of a generic
/// unrelated emoji — keeps in-app branding consistent with what's on the Home
/// Screen. See CLAUDE.md: a stray 🧩 jigsaw emoji shipped here originally and
/// had nothing to do with the Three Kingdoms / Klotski theme.
struct AppEmblem: View {
    var size: CGFloat = 48

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
            .fill(Color(red: 0.78, green: 0.12, blue: 0.10))
            .frame(width: size, height: size)
            .overlay(
                Text("帥")
                    .font(.system(size: size * 0.62, weight: .bold))
                    .foregroundStyle(Color(red: 0.98, green: 0.96, blue: 0.92))
            )
    }
}
