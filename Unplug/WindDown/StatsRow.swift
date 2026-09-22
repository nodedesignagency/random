import SwiftUI

/// Three stats side by side, each with its icon on the left, split by soft fading dividers.
struct StatsRow: View {
    let items: [StatItem]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items.indices, id: \.self) { index in
                if index > 0 {
                    FadingDivider()
                }
                items[index]
                    .frame(maxWidth: .infinity)
            }
        }
    }
}

struct StatItem: View {
    /// Placeholder SF Symbols for now. To use your own artwork, add it to Assets.xcassets and
    /// pass `Image("YourIconName")` instead.
    let icon: Image
    let value: String
    let label: String

    var body: some View {
        HStack(spacing: 8) {
            icon
                .resizable()
                .scaledToFit()
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.white.opacity(0.9))
                .frame(width: 24, height: 24)

            VStack(alignment: .leading, spacing: 1) {
                // Counts roll like an odometer; everything moves vertically only.
                Text(value)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .contentTransition(.numericText())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(label)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
    }
}

/// A thin vertical line that fades out at both ends.
private struct FadingDivider: View {
    var body: some View {
        LinearGradient(
            colors: [.white.opacity(0), .white.opacity(0.18), .white.opacity(0)],
            startPoint: .top,
            endPoint: .bottom
        )
        .frame(width: 1, height: 44)
    }
}
