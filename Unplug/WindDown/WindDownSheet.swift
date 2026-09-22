import SwiftUI

/// Bottom sheet shown while the app puts distracting apps "to bed" for the night.
///
/// Dark night glass: header, the animated bed illustration, a rounded title, the app lineup
/// (which doubles as the loading indicator), a stats strip and a button that turns into
/// "Good night" once everything is asleep, celebrated with a burst of star dust.
struct WindDownSheet: View {
    let onClose: () -> Void

    @State private var model = WindDownModel()
    @State private var hasAppeared = false
    @State private var burstStart: Date?

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    var body: some View {
        // Shrinks the illustration on short screens so the whole sheet always fits.
        ViewThatFits(in: .vertical) {
            content(illustrationHeight: 220)
            content(illustrationHeight: 150)
        }
        .frame(maxWidth: .infinity)
        .background { NightGlassBackground() }
        .overlay { StarBurst(start: burstStart) }
        .onAppear { hasAppeared = true }
        .task { await model.run() }
        .onChange(of: model.isComplete) { _, isComplete in
            if isComplete { burstStart = .now }
        }
        .sensoryFeedback(.impact(weight: .light, intensity: 0.8), trigger: model.tuckedCount)
        .sensoryFeedback(.success, trigger: model.isComplete) { _, isComplete in isComplete }
    }

    private func content(illustrationHeight: CGFloat) -> some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 18)
                .padding(.top, 18)

            SleepIllustration(apps: model.apps, asleepCount: model.tuckedCount, isVisible: hasAppeared)
                .frame(height: illustrationHeight)

            title
                .padding(.top, 10)

            subtitle
                .padding(.top, 6)
                .reveal(hasAppeared, delay: 0.4, y: 10)

            AppLineup(
                apps: model.apps,
                tuckedCount: model.tuckedCount,
                progress: model.progress,
                isVisible: hasAppeared
            )
            .padding(.top, 22)

            stats
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .reveal(hasAppeared, delay: 0.7, scale: 0.95, y: 14)

            SleepActionButton(isComplete: model.isComplete, action: onClose)
                .padding(.top, 20)
                .padding(.horizontal, 20)
                .reveal(hasAppeared, delay: 0.8, scale: 0.8, y: 16)
        }
        .padding(.bottom, 26)
    }

    // MARK: Header

    private var header: some View {
        HStack {
            CloseButton(action: onClose)
                .reveal(hasAppeared, delay: 0.3, scale: 0.4, rotation: -90)
                // Once every app is asleep, "Good night" is the way out, so the ✕ bows out.
                .scaleEffect(model.isComplete ? 0.4 : 1)
                .opacity(model.isComplete ? 0 : 1)
                .blur(radius: model.isComplete ? 4 : 0)
                .allowsHitTesting(!model.isComplete)
                .accessibilityHidden(model.isComplete)
                .animation(.spring(duration: 0.45, bounce: 0.2), value: model.isComplete)

            Spacer()

            HStack(spacing: 6) {
                Image(systemName: "moon.fill")
                    .foregroundStyle(Palette.moon)
                Text("10:30 PM – \(model.wakeTime)")
                    .foregroundStyle(.white.opacity(0.8))
            }
            .font(.system(size: 13, weight: .semibold, design: .rounded))
            .padding(.horizontal, 12)
            .frame(height: 32)
            .background(Capsule().fill(.white.opacity(0.08)))
            .overlay(Capsule().stroke(.white.opacity(0.12), lineWidth: 1))
            .reveal(hasAppeared, delay: 0.35, scale: 0.7)
        }
    }

    // MARK: Title

    private var title: some View {
        ZStack {
            CascadingTitle(
                lines: ["Tucking in your apps"],
                phase: !hasAppeared ? .before : (model.isComplete ? .after : .shown),
                delay: 0.3
            )

            CascadingTitle(
                lines: ["Sweet dreams"],
                phase: model.isComplete ? .shown : .before,
                delay: 0.25
            )
        }
    }

    private var subtitle: some View {
        RisingText(text: subtitleText)
            .font(.system(size: 15, weight: .medium, design: .rounded))
            .foregroundStyle(.white.opacity(0.6))
            .padding(.horizontal, 20)
    }

    private var subtitleText: String {
        if let app = model.currentApp {
            return "\(app.name) is getting sleepy…"
        }
        return "Phones down, lights out. See you at \(model.wakeTime)."
    }

    // MARK: Stats

    private var stats: some View {
        HStack(spacing: 0) {
            statTile(icon: Image(systemName: "moon.zzz.fill"), label: "Apps asleep") {
                HStack(spacing: 0) {
                    Text("\(model.tuckedCount)")
                        .contentTransition(.numericText(value: Double(model.tuckedCount)))
                    Text(" of \(model.apps.count)")
                        .foregroundStyle(.white.opacity(0.45))
                }
            }

            Rectangle()
                .fill(.white.opacity(0.1))
                .frame(width: 1, height: 34)

            statTile(icon: Image(systemName: "sunrise.fill"), label: "Back online") {
                Text(model.wakeTime)
            }
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(.white.opacity(0.09), lineWidth: 1)
        )
    }

    /// One half of the stats box: icon on the left, value and label stacked beside it.
    /// The icons are placeholder SF Symbols; to use your own, add them to Assets.xcassets and
    /// pass `Image("YourIconName")` above.
    private func statTile<Value: View>(
        icon: Image,
        label: String,
        @ViewBuilder value: () -> Value
    ) -> some View {
        HStack(spacing: 10) {
            icon
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.85))
                .frame(width: 26, height: 26)

            VStack(alignment: .leading, spacing: 4) {
                value()
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview("Sheet") {
    ZStack(alignment: .bottom) {
        NightSky().ignoresSafeArea()
        WindDownSheet {}
            .clipShape(RoundedRectangle(cornerRadius: 40, style: .continuous))
            .padding(10)
    }
}
