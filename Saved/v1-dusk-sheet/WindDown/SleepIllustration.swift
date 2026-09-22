import SwiftUI

/// The bed illustration, split into layers so each piece can move on its own:
/// the moon floats and glows, stars twinkle, the bed breathes, awake apps buzz with
/// notification badges, and once an app is tucked in its badge pops and little "z"s drift up.
///
/// All geometry is in the source artwork's pixel space (see `Artboard`) and scaled to fit.
struct SleepIllustration: View {
    let apps: [SleepyApp]
    let asleepCount: Int
    let isVisible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(apps: [SleepyApp], asleepCount: Int, isVisible: Bool) {
        self.apps = apps
        self.asleepCount = asleepCount
        self.isVisible = isVisible
    }

    var body: some View {
        GeometryReader { proxy in
            let k = proxy.size.width / Artboard.size.width

            TimelineView(.animation(paused: reduceMotion)) { context in
                let t = context.date.timeIntervalSinceReferenceDate

                ZStack(alignment: .topLeading) {
                    halo(t: t, k: k)
                    sparkles(t: t, k: k)
                    star("SleepStarLeft", in: Artboard.starLeft, t: t, k: k, period: 2.6, phase: 0, delay: 0.4)
                    star("SleepStarRight", in: Artboard.starRight, t: t, k: k, period: 3.1, phase: 1.3, delay: 0.48)
                    star("SleepStarSmall", in: Artboard.starSmall, t: t, k: k, period: 2.2, phase: 2.1, delay: 0.56)
                    moon(t: t, k: k)
                    bed(t: t, k: k)

                    ForEach(apps) { app in
                        badge(for: app, t: t, k: k)
                        dreams(for: app, t: t, k: k)
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: .topLeading)
            }
        }
        .aspectRatio(Artboard.size, contentMode: .fit)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Instagram, TikTok and X tucked into bed under a crescent moon")
        .accessibilityAddTraits(.isImage)
    }

    // MARK: Sky

    private func halo(t: Double, k: CGFloat) -> some View {
        let r = Artboard.moon
        let pulse = (sin(t * 1.6) + 1) / 2

        return Circle()
            .fill(
                RadialGradient(
                    colors: [Palette.moonGlow.opacity(0.9), Palette.moonGlow.opacity(0)],
                    center: .center,
                    startRadius: 0,
                    endRadius: 280 * k
                )
            )
            .frame(width: 560 * k, height: 560 * k)
            .scaleEffect(0.9 + 0.12 * CGFloat(pulse))
            .opacity(0.45 + 0.4 * pulse)
            .reveal(isVisible, delay: 0.3, scale: 0.4)
            .position(x: r.midX * k, y: r.midY * k)
    }

    private func moon(t: Double, k: CGFloat) -> some View {
        let r = Artboard.moon
        let float = CGFloat(sin(t * 1.3)) * 9 * k
        let sway = sin(t * 0.8) * 5

        return Image("SleepMoon")
            .resizable()
            .frame(width: r.width * k, height: r.height * k)
            .reveal(isVisible, delay: 0.22, scale: 0.6, y: -70 * k, rotation: -35)
            .rotationEffect(.degrees(sway))
            .offset(y: float)
            .position(x: r.midX * k, y: r.midY * k)
    }

    private func star(
        _ name: String,
        in r: CGRect,
        t: Double,
        k: CGFloat,
        period: Double,
        phase: Double,
        delay: Double
    ) -> some View {
        let wave = sin(t * 2 * .pi / period + phase)

        return Image(name)
            .resizable()
            .frame(width: r.width * k, height: r.height * k)
            .scaleEffect(1 + 0.18 * CGFloat(wave))
            .rotationEffect(.degrees(10 * wave))
            .opacity(0.8 + 0.2 * wave)
            .reveal(isVisible, delay: delay, scale: 0.1, rotation: -120)
            .position(x: r.midX * k, y: r.midY * k)
    }

    private func sparkles(t: Double, k: CGFloat) -> some View {
        ZStack {
            ForEach(Artboard.sparkles.indices, id: \.self) { index in
                let point = Artboard.sparkles[index]
                let life = fract(t / 3.4 + Double(index) * 0.29)
                let glow = sin(life * .pi)

                Image(systemName: "sparkle")
                    .font(.system(size: 44 * k, weight: .bold))
                    .foregroundStyle(Palette.moon)
                    .scaleEffect(0.3 + 0.7 * CGFloat(glow))
                    .rotationEffect(.degrees(life * 90))
                    .opacity(glow)
                    .position(x: point.x * k, y: point.y * k)
            }
        }
        .reveal(isVisible, delay: 0.7, scale: 1)
    }

    // MARK: Bed

    private func bed(t: Double, k: CGFloat) -> some View {
        let r = Artboard.bed
        let breath = CGFloat(sin(t * 1.4))

        return Image("SleepBed")
            .resizable()
            .frame(width: r.width * k, height: r.height * k)
            .scaleEffect(x: 1 + 0.004 * breath, y: 1 + 0.012 * breath, anchor: .bottom)
            .reveal(isVisible, delay: 0.05, scale: 0.86, y: 50 * k)
            .position(x: r.midX * k, y: r.midY * k)
    }

    /// Red notification badge that buzzes every couple of seconds while the app is awake,
    /// then pops (with a soft ring) the moment it's tucked in.
    private func badge(for app: SleepyApp, t: Double, k: CGFloat) -> some View {
        let center = Artboard.badgeCenters[app.id]
        let isAwake = app.id >= asleepCount
        let size = 80 * k

        // Each app buzzes on its own beat.
        let beat = fract(t / 2.3 + Double(app.id) * 0.33)
        let buzz = beat < 0.2 ? sin(beat / 0.2 * .pi) : 0
        let wiggle = sin(t * 55) * 14 * buzz

        return ZStack {
            if isAwake {
                Text("\(app.unread)")
                    .font(.system(size: 40 * k, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(.white)
                    .frame(width: size, height: size)
                    .background(Circle().fill(Palette.badge))
                    .overlay(Circle().stroke(Color.white, lineWidth: 6 * k))
                    .shadow(color: Palette.badge.opacity(0.45), radius: 10 * k, y: 4 * k)
                    .rotationEffect(.degrees(wiggle))
                    .scaleEffect(1 + 0.14 * CGFloat(buzz))
                    .transition(
                        .asymmetric(
                            insertion: .scale.combined(with: .opacity),
                            removal: .scale(scale: 2.2).combined(with: .opacity)
                        )
                    )
            } else {
                Circle()
                    .stroke(Palette.moon, lineWidth: 5 * k)
                    .frame(width: size, height: size)
                    .transition(.burst)
            }
        }
        .frame(width: size, height: size)
        .reveal(isVisible, delay: 0.62 + Double(app.id) * 0.08, scale: 0.2)
        .position(x: center.x * k, y: center.y * k)
    }

    /// A lazy stream of "z"s rising from an app once it's asleep.
    private func dreams(for app: SleepyApp, t: Double, k: CGFloat) -> some View {
        let origin = Artboard.dreamOrigins[app.id]
        let drift = Artboard.dreamDrift[app.id]
        let isAsleep = app.id < asleepCount

        return ZStack {
            ForEach(0..<2, id: \.self) { index in
                let p = CGFloat(fract(t / 3.2 + Double(index) * 0.5 + Double(app.id) * 0.23))
                let x = origin.x + drift * p + 12 * sin(p * 2 * .pi)
                let y = origin.y - 150 * p

                Text("z")
                    .font(.system(size: 64 * k, weight: .heavy, design: .rounded))
                    .foregroundStyle(Palette.dream)
                    .shadow(color: .white.opacity(0.8), radius: 4 * k)
                    .scaleEffect(0.5 + 0.6 * p)
                    .rotationEffect(.degrees(Double(-14 + 26 * p)))
                    .opacity(Double(sin(p * .pi)))
                    .position(x: x * k, y: y * k)
            }
        }
        .opacity(isAsleep ? 1 : 0)
        .animation(.easeInOut(duration: 0.9), value: isAsleep)
    }
}

// MARK: - Artwork geometry

/// Positions of each layer inside the original 1233 × 1275 px artwork, re-based onto the
/// region the illustration actually shows.
private enum Artboard {
    static let origin = CGPoint(x: 100, y: 60)
    static let size = CGSize(width: 990, height: 1120)

    static let moon = rect(478, 110, 266, 255)
    static let starLeft = rect(387, 267, 93, 90)
    static let starRight = rect(760, 214, 97, 97)
    static let starSmall = rect(822, 295, 74, 74)
    static let bed = rect(128, 380, 933, 781)

    /// Top-right corner of each app icon, in app order (Instagram, TikTok, X).
    static let badgeCenters = [point(510, 512), point(728, 516), point(935, 552)]
    /// Where each app's "z"s start, and how far they drift sideways as they rise.
    static let dreamOrigins = [point(425, 470), point(640, 478), point(855, 505)]
    static let dreamDrift: [CGFloat] = [-50, 25, 70]

    static let sparkles = [point(395, 190), point(905, 165), point(335, 380), point(1010, 330)]

    private static func rect(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        CGRect(x: x - origin.x, y: y - origin.y, width: width, height: height)
    }

    private static func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        CGPoint(x: x - origin.x, y: y - origin.y)
    }
}

// MARK: - Burst transition

/// A ring that expands and fades out as it's inserted, then stays invisible.
private struct BurstEffect: ViewModifier {
    let progress: CGFloat

    func body(content: Content) -> some View {
        content
            .scaleEffect(0.6 + 1.8 * progress)
            .opacity(Double(1 - progress))
    }
}

private extension AnyTransition {
    static var burst: AnyTransition {
        .asymmetric(
            insertion: .modifier(active: BurstEffect(progress: 0), identity: BurstEffect(progress: 1)),
            removal: .identity
        )
    }
}

#Preview {
    SleepIllustration(
        apps: [
            SleepyApp(id: 0, name: "Instagram", unread: 12),
            SleepyApp(id: 1, name: "TikTok", unread: 8),
            SleepyApp(id: 2, name: "X", unread: 5),
        ],
        asleepCount: 1,
        isVisible: true
    )
    .frame(height: 300)
    .padding()
    .background(DuskBackground())
}
