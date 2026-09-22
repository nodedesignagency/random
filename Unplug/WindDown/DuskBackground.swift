import SwiftUI

/// The sheet's surface: a slowly drifting mesh from warm moonlight at the top
/// to periwinkle dusk at the bottom.
struct DuskBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        TimelineView(.animation(paused: reduceMotion)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            MeshGradient(
                width: 3,
                height: 3,
                points: Self.points(at: t),
                colors: Self.colors
            )
        }
        .overlay(alignment: .top) {
            // Moonlight pooling behind the illustration.
            RadialGradient(
                colors: [Palette.moonGlow.opacity(0.6), Palette.moonGlow.opacity(0)],
                center: .center,
                startRadius: 0,
                endRadius: 190
            )
            .frame(width: 380, height: 380)
            .offset(y: -30)
        }
    }

    private static let colors: [Color] = [
        Palette.cream, Palette.creamWarm, Palette.lilacMist,
        Palette.lavender, Palette.lavenderLight, Palette.lavenderDeep,
        Palette.periwinkle, Palette.periwinkleLight, Palette.periwinkleDeep,
    ]

    private static func points(at t: Double) -> [SIMD2<Float>] {
        func point(_ x: Double, _ y: Double) -> SIMD2<Float> {
            SIMD2<Float>(Float(x), Float(y))
        }

        return [
            point(0, 0),
            point(0.5 + 0.08 * sin(t * 0.35), 0),
            point(1, 0),

            point(0, 0.45 + 0.06 * sin(t * 0.5)),
            point(0.5 + 0.1 * sin(t * 0.42), 0.5 + 0.07 * cos(t * 0.37)),
            point(1, 0.5 + 0.06 * cos(t * 0.45)),

            point(0, 1),
            point(0.5 + 0.1 * cos(t * 0.3), 1),
            point(1, 1),
        ]
    }
}
