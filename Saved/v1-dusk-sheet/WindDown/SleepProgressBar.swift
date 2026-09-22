import SwiftUI

/// A moonlight-coloured progress capsule with a highlight that keeps sweeping across the fill.
struct SleepProgressBar: View {
    let progress: Double
    let isComplete: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(progress: Double, isComplete: Bool) {
        self.progress = progress
        self.isComplete = isComplete
    }

    var body: some View {
        GeometryReader { proxy in
            let fillWidth = max(proxy.size.height, proxy.size.width * CGFloat(progress))

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.5))
                    .overlay(Capsule().stroke(Color.white.opacity(0.7), lineWidth: 0.5))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Palette.moonGlow, Palette.moon],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .overlay {
                        shimmer
                            .clipShape(Capsule())
                    }
                    .frame(width: fillWidth)
                    .shadow(color: Palette.moon.opacity(isComplete ? 0.95 : 0.55), radius: isComplete ? 10 : 5)
                    .opacity(progress > 0 ? 1 : 0)
            }
        }
        .accessibilityElement()
        .accessibilityLabel("Wind-down progress")
        .accessibilityValue("\(Int((progress * 100).rounded())) percent")
    }

    private var shimmer: some View {
        TimelineView(.animation(paused: reduceMotion || isComplete)) { context in
            let cycle = context.date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: 1.6) / 1.6
            GeometryReader { proxy in
                let band = max(proxy.size.width * 0.35, 24)
                LinearGradient(
                    colors: [.white.opacity(0), .white.opacity(0.85), .white.opacity(0)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .frame(width: band)
                .offset(x: -band + (proxy.size.width + band) * CGFloat(cycle))
            }
        }
        .opacity(isComplete ? 0 : 1)
    }
}
