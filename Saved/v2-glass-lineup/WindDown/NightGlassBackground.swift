import SwiftUI

/// The sheet's surface: frosted night glass with two soft aurora lights drifting behind it
/// and moonlight pooling where the illustration sits.
struct NightGlassBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)

            LinearGradient(
                colors: [Palette.glassTop.opacity(0.82), Palette.glassBottom.opacity(0.94)],
                startPoint: .top,
                endPoint: .bottom
            )

            TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { context in
                let t = context.date.timeIntervalSinceReferenceDate
                GeometryReader { proxy in
                    let w = proxy.size.width
                    let h = proxy.size.height

                    Circle()
                        .fill(Palette.aurora.opacity(0.45))
                        .frame(width: w * 0.9, height: w * 0.9)
                        .blur(radius: 70)
                        .position(
                            x: w * (0.2 + 0.12 * CGFloat(sin(t * 0.23))),
                            y: h * (0.62 + 0.08 * CGFloat(cos(t * 0.19)))
                        )

                    Circle()
                        .fill(Palette.auroraPink.opacity(0.22))
                        .frame(width: w * 0.7, height: w * 0.7)
                        .blur(radius: 70)
                        .position(
                            x: w * (0.85 + 0.1 * CGFloat(cos(t * 0.27))),
                            y: h * (0.85 + 0.06 * CGFloat(sin(t * 0.21)))
                        )
                }
            }

            RadialGradient(
                colors: [Palette.moonGlow.opacity(0.26), Palette.moonGlow.opacity(0)],
                center: UnitPoint(x: 0.5, y: 0.2),
                startRadius: 0,
                endRadius: 230
            )
        }
        .allowsHitTesting(false)
    }
}
