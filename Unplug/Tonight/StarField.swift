import SwiftUI

/// A quiet night sky: a dusk gradient with softly twinkling stars.
struct NightSky: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [Palette.nightTop, Palette.nightMid, Palette.nightBottom],
                startPoint: .top,
                endPoint: .bottom
            )

            RadialGradient(
                colors: [Palette.moonGlow.opacity(0.22), .clear],
                center: UnitPoint(x: 0.82, y: 0.08),
                startRadius: 0,
                endRadius: 320
            )

            StarField()
        }
    }
}

struct StarField: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private struct Star {
        let x: CGFloat
        let y: CGFloat
        let size: CGFloat
        let speed: Double
        let phase: Double
    }

    /// Deterministic "random" layout so the sky doesn't reshuffle on every redraw.
    private static let stars: [Star] = (0..<70).map { index in
        Star(
            x: CGFloat(noise(index, 1)),
            y: CGFloat(pow(noise(index, 2), 1.6) * 0.75),
            size: CGFloat(0.8 + noise(index, 3) * 1.8),
            speed: 0.6 + noise(index, 4) * 1.6,
            phase: noise(index, 5) * .pi * 2
        )
    }

    private static func noise(_ index: Int, _ salt: Double) -> Double {
        fract(sin(Double(index) * 12.9898 + salt * 78.233) * 43758.5453)
    }

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: reduceMotion)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            Canvas { canvas, size in
                for star in Self.stars {
                    let twinkle = 0.5 + 0.5 * sin(t * star.speed + star.phase)
                    let rect = CGRect(
                        x: star.x * size.width,
                        y: star.y * size.height,
                        width: star.size,
                        height: star.size
                    )
                    canvas.opacity = 0.15 + 0.7 * twinkle
                    canvas.fill(Path(ellipseIn: rect), with: .color(.white))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }
}
