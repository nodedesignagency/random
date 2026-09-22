import SwiftUI

/// A spinner that, once the work is done, pops into a filled disc and draws a check mark.
struct StatusIndicator: View {
    let isComplete: Bool

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    init(isComplete: Bool) {
        self.isComplete = isComplete
    }

    var body: some View {
        ZStack {
            spinner
                .scaleEffect(isComplete ? 0.5 : 1)
                .opacity(isComplete ? 0 : 1)
                .animation(.easeIn(duration: 0.2), value: isComplete)

            Circle()
                .fill(Palette.ink)
                .scaleEffect(isComplete ? 1 : 0.2)
                .opacity(isComplete ? 1 : 0)
                .animation(.spring(duration: 0.45, bounce: 0.5), value: isComplete)

            Checkmark()
                .trim(from: 0, to: isComplete ? 1 : 0)
                .stroke(Color.white, style: StrokeStyle(lineWidth: 2.2, lineCap: .round, lineJoin: .round))
                .padding(5)
                .animation(.easeOut(duration: 0.35).delay(0.2), value: isComplete)
        }
        .accessibilityHidden(true)
    }

    private var spinner: some View {
        ZStack {
            Circle()
                .stroke(Palette.ink.opacity(0.15), lineWidth: 2)

            TimelineView(.animation(paused: isComplete || reduceMotion)) { context in
                let degrees = (context.date.timeIntervalSinceReferenceDate * 330)
                    .truncatingRemainder(dividingBy: 360)
                Circle()
                    .trim(from: 0, to: 0.3)
                    .stroke(Palette.ink.opacity(0.6), style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .rotationEffect(.degrees(degrees))
            }
        }
    }
}

struct Checkmark: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.2, y: rect.minY + rect.height * 0.52))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.42, y: rect.minY + rect.height * 0.72))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.8, y: rect.minY + rect.height * 0.3))
        return path
    }
}
