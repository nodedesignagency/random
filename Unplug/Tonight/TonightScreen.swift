import SwiftUI

/// Placeholder home screen for the detox app. Its only job for now is to launch the wind-down sheet.
struct TonightScreen: View {
    let onStart: () -> Void

    @State private var hasAppeared = false

    init(onStart: @escaping () -> Void) {
        self.onStart = onStart
    }

    var body: some View {
        ZStack {
            NightSky()
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Text("TONIGHT")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(2)
                    .foregroundStyle(.white.opacity(0.5))
                    .reveal(hasAppeared, delay: 0.05, y: 10)

                Text("Time to\nwind down")
                    .font(.system(size: 44, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                    .reveal(hasAppeared, delay: 0.12, y: 14)

                scheduleCard
                    .padding(.top, 32)
                    .reveal(hasAppeared, delay: 0.22, scale: 0.96, y: 18)

                appsCard
                    .padding(.top, 14)
                    .reveal(hasAppeared, delay: 0.3, scale: 0.96, y: 18)

                Spacer(minLength: 24)

                startButton
                    .reveal(hasAppeared, delay: 0.4, scale: 0.9, y: 24)
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 12)
        }
        .onAppear { hasAppeared = true }
    }

    private var scheduleCard: some View {
        HStack(spacing: 0) {
            scheduleItem(symbol: "moon.fill", label: "Bedtime", time: "10:30 PM")
            Rectangle()
                .fill(.white.opacity(0.12))
                .frame(width: 1, height: 44)
            scheduleItem(symbol: "sunrise.fill", label: "Wake up", time: "7:00 AM")
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(glassCard)
    }

    private func scheduleItem(symbol: String, label: String, time: String) -> some View {
        VStack(spacing: 6) {
            Label(label, systemImage: symbol)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))
            Text(time)
                .font(.system(size: 26, weight: .semibold, design: .serif))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }

    private var appsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Going to sleep")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.white.opacity(0.55))

            HStack(spacing: 8) {
                appChip("Instagram", tint: Color(hex: 0xF0487E))
                appChip("TikTok", tint: Color(hex: 0x3FE8E4))
                appChip("X", tint: .white)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(glassCard)
    }

    private func appChip(_ name: String, tint: Color) -> some View {
        HStack(spacing: 7) {
            Circle()
                .fill(tint)
                .frame(width: 7, height: 7)
            Text(name)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Capsule().fill(.white.opacity(0.08)))
    }

    private var glassCard: some View {
        RoundedRectangle(cornerRadius: 24, style: .continuous)
            .fill(.white.opacity(0.07))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            }
    }

    private var startButton: some View {
        Button(action: onStart) {
            HStack(spacing: 10) {
                Image(systemName: "moon.zzz.fill")
                    .symbolEffect(.pulse)
                Text("Start wind down")
            }
            .font(.system(size: 18, weight: .semibold))
            .foregroundStyle(Palette.ink)
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background {
                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Palette.moonGlow, Palette.moon],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: Palette.moon.opacity(0.35), radius: 18, y: 6)
            }
        }
        .buttonStyle(PressableButtonStyle(pressedScale: 0.96))
    }
}

#Preview {
    TonightScreen {}
        .preferredColorScheme(.dark)
}
