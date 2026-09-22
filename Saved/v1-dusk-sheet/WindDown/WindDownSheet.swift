import SwiftUI

/// Bottom sheet shown while the app puts distracting apps "to bed" for the night.
///
/// Layout follows the reference (close button, illustration, progress, status, serif title);
/// every element enters with its own staggered spring and keeps gently moving while it waits.
struct WindDownSheet: View {
    let onClose: () -> Void

    @State private var model = WindDownModel()
    @State private var hasAppeared = false

    init(onClose: @escaping () -> Void) {
        self.onClose = onClose
    }

    var body: some View {
        VStack(spacing: 0) {
            SleepIllustration(apps: model.apps, asleepCount: model.tuckedCount, isVisible: hasAppeared)
                .frame(height: 280)
                .padding(.top, 48)

            SleepProgressBar(progress: model.progress, isComplete: model.isComplete)
                .frame(width: 200, height: 8)
                .padding(.top, 26)
                .reveal(hasAppeared, delay: 0.32, scale: 0.7, y: 10)

            statusRow
                .padding(.top, 30)
                .reveal(hasAppeared, delay: 0.4, y: 12)

            title
                .padding(.top, 12)
                .padding(.horizontal, 24)
        }
        .padding(.bottom, 44)
        .frame(maxWidth: .infinity)
        .overlay(alignment: .topTrailing) {
            CloseButton(action: onClose)
                .reveal(hasAppeared, delay: 0.5, scale: 0.4, rotation: -90)
                .padding(16)
        }
        .background { DuskBackground() }
        .onAppear { hasAppeared = true }
        .task { await model.run() }
        .sensoryFeedback(.impact(weight: .light, intensity: 0.8), trigger: model.tuckedCount)
        .sensoryFeedback(.success, trigger: model.isComplete) { _, isComplete in isComplete }
    }

    // MARK: Status

    private var statusRow: some View {
        HStack(spacing: 10) {
            StatusIndicator(isComplete: model.isComplete)
                .frame(width: 20, height: 20)

            // Each new message pushes the previous one up and out.
            ZStack {
                Text(statusText)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(Palette.inkSoft)
                    .id(statusText)
                    .transition(.push(from: .bottom))
            }
        }
        .accessibilityElement(children: .combine)
    }

    private var statusText: String {
        if let app = model.currentApp {
            return "Tucking in \(app.name)…"
        }
        return "\(model.apps.count) apps asleep until \(model.wakeTime)"
    }

    // MARK: Title

    private var title: some View {
        ZStack {
            CascadingTitle(
                lines: ["Putting your apps", "to bed"],
                phase: !hasAppeared ? .before : (model.isComplete ? .after : .shown),
                delay: 0.45
            )

            CascadingTitle(
                lines: ["Sweet dreams.", "See you at \(model.wakeTimeShort)"],
                phase: model.isComplete ? .shown : .before,
                delay: 0.3
            )
        }
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
