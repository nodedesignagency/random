import SwiftUI

/// The loading indicator: each app sits in a ring that fills with moonlight while it's
/// being tucked in. Once asleep it dims, gets a little moon badge, and the thread to the
/// next app lights up.
struct AppLineup: View {
    let apps: [SleepyApp]
    let tuckedCount: Int
    /// Overall progress, 0...1, spread evenly across the apps.
    let progress: Double
    let isVisible: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(apps: [SleepyApp], tuckedCount: Int, progress: Double, isVisible: Bool) {
        self.apps = apps
        self.tuckedCount = tuckedCount
        self.progress = progress
        self.isVisible = isVisible
    }

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(apps) { app in
                if app.id > 0 {
                    thread(isLit: app.id <= tuckedCount)
                        .reveal(isVisible, delay: 0.5 + Double(app.id) * 0.1, scale: 0.4)
                }
                tile(for: app)
                    .reveal(isVisible, delay: 0.45 + Double(app.id) * 0.1, scale: 0.5, y: 16)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("\(tuckedCount) of \(apps.count) apps asleep")
    }

    private func ringFill(for app: SleepyApp) -> CGFloat {
        let raw = progress * Double(apps.count) - Double(app.id)
        return CGFloat(min(max(raw, 0), 1))
    }

    private func tile(for app: SleepyApp) -> some View {
        let isAsleep = app.id < tuckedCount
        let isCurrent = app.id == tuckedCount

        return VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.07))

                Circle()
                    .stroke(Color.white.opacity(0.12), lineWidth: 3)

                Circle()
                    .trim(from: 0, to: ringFill(for: app))
                    .stroke(
                        LinearGradient(
                            colors: [Palette.moonGlow, Palette.moon],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .shadow(color: Palette.moon.opacity(0.6), radius: 6)

                AppGlyph(app: app)
                    .frame(width: 34, height: 34)
                    .saturation(isAsleep ? 0.2 : 1)
                    .opacity(isAsleep ? 0.55 : 1)
                    .scaleEffect(isAsleep ? 0.86 : 1)

                sleepBadge
                    .scaleEffect(isAsleep ? 1 : 0.1)
                    .opacity(isAsleep ? 1 : 0)
                    .offset(x: 20, y: 20)
                    .animation(.spring(duration: 0.5, bounce: 0.55), value: isAsleep)
            }
            .frame(width: 60, height: 60)
            .modifier(Breathing(isActive: isCurrent && isVisible && !reduceMotion))

            ZStack {
                Text(isAsleep ? "Asleep" : app.name)
                    .font(.system(size: 12, weight: .semibold, design: .rounded))
                    .foregroundStyle(isAsleep ? Palette.moon : Color.white.opacity(0.6))
                    .id(isAsleep)
                    .transition(.rise)
            }
            .frame(height: 16)
        }
        .frame(width: 74)
    }

    private var sleepBadge: some View {
        Image(systemName: "moon.fill")
            .font(.system(size: 10, weight: .bold))
            .foregroundStyle(Palette.ink)
            .frame(width: 22, height: 22)
            .background(Circle().fill(Palette.moon))
            .overlay(Circle().stroke(Palette.glassBottom, lineWidth: 2))
    }

    /// The little line between two apps; lights up once the app on its left is asleep.
    private func thread(isLit: Bool) -> some View {
        ZStack(alignment: .leading) {
            Capsule()
                .fill(Color.white.opacity(0.1))
            Capsule()
                .fill(Palette.moon)
                .frame(width: isLit ? 22 : 0)
                .shadow(color: Palette.moon.opacity(0.7), radius: 4)
        }
        .frame(width: 22, height: 3)
        .frame(height: 60)
        .animation(.easeInOut(duration: 0.5), value: isLit)
    }
}

/// Gentle in-and-out pulse for the app currently being tucked in.
private struct Breathing: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        TimelineView(.animation(paused: !isActive)) { context in
            let t = context.date.timeIntervalSinceReferenceDate
            content
                .scaleEffect(isActive ? 1 + 0.05 * CGFloat(sin(t * 4)) : 1)
        }
        .animation(.easeOut(duration: 0.3), value: isActive)
    }
}

/// Each app's logo, clipped to the same rounded-square shape so the row looks consistent.
/// The logos live in Assets.xcassets (LogoInstagram, LogoTikTok, LogoX); the originals are in
/// `Design/AppIcons/`.
struct AppGlyph: View {
    let app: SleepyApp

    var body: some View {
        Image(logoName)
            .resizable()
            .scaledToFit()
            // TikTok's logo is a circle on black; the black tile behind it makes it read as a square.
            .background(Color.black)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .stroke(Color.white.opacity(0.12), lineWidth: 0.5)
            )
    }

    private var logoName: String {
        switch app.name {
        case "Instagram": "LogoInstagram"
        case "TikTok": "LogoTikTok"
        default: "LogoX"
        }
    }
}
