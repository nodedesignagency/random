import SwiftUI

/// Bottom action. While apps are being tucked in it's a compact pill with a spinning sparkle;
/// when everything is asleep it grows into a full-width glowing "Good night" button.
struct SleepActionButton: View {
    let isComplete: Bool
    let action: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(isComplete: Bool, action: @escaping () -> Void) {
        self.isComplete = isComplete
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 9) {
                ZStack {
                    spinner
                        .opacity(isComplete ? 0 : 1)
                        .scaleEffect(isComplete ? 0.3 : 1)
                    Image(systemName: "moon.stars.fill")
                        .opacity(isComplete ? 1 : 0)
                        .scaleEffect(isComplete ? 1 : 0.3)
                        .rotationEffect(.degrees(isComplete ? 0 : -60))
                }
                .frame(width: 20, height: 20)

                ZStack {
                    Text(isComplete ? "Good night" : "Tucking in…")
                        .id(isComplete)
                        .transition(.push(from: .bottom))
                }
            }
            .font(.system(size: 17, weight: .semibold, design: .rounded))
            .foregroundStyle(isComplete ? Palette.ink : Color.white)
            .padding(.horizontal, 24)
            .frame(height: 54)
            .frame(maxWidth: isComplete ? .infinity : nil)
            .background {
                ZStack {
                    Capsule()
                        .fill(Color.white.opacity(0.12))
                        .overlay(Capsule().stroke(Color.white.opacity(0.18), lineWidth: 1))
                        .opacity(isComplete ? 0 : 1)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Palette.moonGlow, Palette.moon],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: Palette.moon.opacity(0.5), radius: 18, y: 6)
                        .opacity(isComplete ? 1 : 0)
                }
            }
            .contentShape(Capsule())
        }
        .buttonStyle(PressableButtonStyle(pressedScale: 0.95))
        .disabled(!isComplete)
        .animation(.spring(duration: 0.65, bounce: 0.3), value: isComplete)
        .accessibilityLabel(isComplete ? "Good night" : "Tucking in apps")
    }

    private var spinner: some View {
        TimelineView(.animation(paused: isComplete || reduceMotion)) { context in
            let degrees = (context.date.timeIntervalSinceReferenceDate * 240)
                .truncatingRemainder(dividingBy: 360)
            Image(systemName: "sparkle")
                .rotationEffect(.degrees(degrees))
        }
    }
}
