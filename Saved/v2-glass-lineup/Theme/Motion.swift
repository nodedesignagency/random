import SwiftUI

/// Fractional part of `x`, always in `0..<1`. Handy for looping time-based motion.
func fract(_ x: Double) -> Double {
    x - x.rounded(.down)
}

/// Springs a view in from a hidden pose (smaller, shifted, rotated, transparent).
/// Only the entrance is animated here, so per-frame motion layered on top of it
/// never interrupts the spring.
struct Reveal: ViewModifier {
    let isVisible: Bool
    let delay: Double
    var scale: CGFloat = 0.9
    var y: CGFloat = 0
    var rotation: Double = 0

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1 : scale)
            .rotationEffect(.degrees(isVisible ? 0 : rotation))
            .offset(y: isVisible ? 0 : y)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(duration: 0.8, bounce: 0.32).delay(delay), value: isVisible)
    }
}

extension View {
    func reveal(
        _ isVisible: Bool,
        delay: Double,
        scale: CGFloat = 0.9,
        y: CGFloat = 0,
        rotation: Double = 0
    ) -> some View {
        modifier(Reveal(isVisible: isVisible, delay: delay, scale: scale, y: y, rotation: rotation))
    }
}

/// Squishes a button while it is held down and bounces back on release.
struct PressableButtonStyle: ButtonStyle {
    var pressedScale: CGFloat = 0.9

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? pressedScale : 1)
            .animation(.spring(duration: 0.3, bounce: 0.5), value: configuration.isPressed)
    }
}
