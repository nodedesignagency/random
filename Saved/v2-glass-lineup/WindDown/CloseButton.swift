import SwiftUI

struct CloseButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 40, height: 40)
                .background(Circle().fill(.white.opacity(0.1)))
                .overlay(Circle().stroke(.white.opacity(0.16), lineWidth: 1))
                .contentShape(Circle())
        }
        .buttonStyle(PressableButtonStyle(pressedScale: 0.86))
        .accessibilityLabel("Close")
    }
}
