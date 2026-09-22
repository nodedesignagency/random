import SwiftUI

/// A one-shot burst of star dust and confetti, fired when every app is asleep.
/// Pass the moment it should start; `nil` keeps it hidden.
struct StarBurst: View {
    let start: Date?
    /// Where the burst comes from, as a fraction of the view's size.
    var origin = UnitPoint(x: 0.5, y: 0.28)

    private static let duration = 2.6
    private static let colors: [Color] = [
        Palette.moon, Palette.moonGlow, Palette.mist, Palette.auroraPink, Color(hex: 0x7FE7C4), .white,
    ]

    private struct Particle {
        let angle: Double
        let speed: Double
        let spin: Double
        let size: CGFloat
        let color: Color
        let isConfetti: Bool
        let delay: Double
    }

    private static let particles: [Particle] = (0..<70).map { index in
        let r1 = noise(index, 1)
        let r2 = noise(index, 2)
        return Particle(
            // Mostly upward and outward, like the confetti in a cannon.
            angle: -Double.pi / 2 + (r1 - 0.5) * Double.pi * 1.5,
            speed: 180 + r2 * 320,
            spin: (noise(index, 3) - 0.5) * 12,
            size: CGFloat(4 + noise(index, 4) * 5),
            color: colors[index % colors.count],
            isConfetti: index % 3 != 0,
            delay: noise(index, 5) * 0.15
        )
    }

    private static func noise(_ index: Int, _ salt: Double) -> Double {
        fract(sin(Double(index) * 91.345 + salt * 47.853) * 24634.6345)
    }

    var body: some View {
        TimelineView(.animation(paused: !isRunning(at: .now))) { context in
            Canvas { canvas, size in
                guard let start else { return }
                let age = context.date.timeIntervalSince(start)
                guard age >= 0, age < Self.duration else { return }

                let from = CGPoint(x: size.width * origin.x, y: size.height * origin.y)
                for particle in Self.particles {
                    let t = age - particle.delay
                    guard t > 0 else { continue }

                    // Fast launch that slows down, then gravity takes over.
                    let travel = particle.speed * (1 - exp(-t * 2.4)) / 2.4
                    let fall = 140 * t * t
                    let x = from.x + CGFloat(cos(particle.angle) * travel)
                    let y = from.y + CGFloat(sin(particle.angle) * travel + fall)
                    let fade = max(0, 1 - t / (Self.duration - 0.3))

                    var piece = canvas
                    piece.opacity = fade
                    piece.translateBy(x: x, y: y)
                    piece.rotate(by: .radians(particle.spin * t))

                    let s = particle.size
                    let shape = particle.isConfetti
                        ? Path(roundedRect: CGRect(x: -s / 2, y: -s * 0.3, width: s, height: s * 0.6), cornerRadius: 1.5)
                        : Path(ellipseIn: CGRect(x: -s / 2, y: -s / 2, width: s, height: s))
                    piece.fill(shape, with: .color(particle.color))
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private func isRunning(at date: Date) -> Bool {
        guard let start else { return false }
        return date.timeIntervalSince(start) < Self.duration
    }
}
