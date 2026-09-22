import SwiftUI

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Palette.ink.opacity(0.75))
                .frame(width: 42, height: 42)
                .background(Circle().fill(.white.opacity(0.6)))
                .overlay(Circle().stroke(.white.opacity(0.85), lineWidth: 1))
                .shadow(color: Palette.ink.opacity(0.1), radius: 8, y: 3)
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle(pressedScale: 0.86))
        .accessibilityLabel("Close")
    }
}
