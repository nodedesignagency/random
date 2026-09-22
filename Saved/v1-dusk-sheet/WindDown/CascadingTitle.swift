import SwiftUI

enum RevealPhase: Equatable {
    /// Not shown yet: waiting just below its resting place.
    case before
    case shown
    /// Replaced by something newer: drifted up and away.
    case after
}

/// A serif headline whose words rise into place one after another, and float away the same way.
struct CascadingTitle: View {
    let lines: [String]
    let phase: RevealPhase
    var delay: Double = 0
    var fontSize: CGFloat = 32

    private struct Word: Identifiable {
        let id: Int
        let line: Int
        let text: String
    }

    private var allWords: [Word] {
        var result: [Word] = []
        for (lineIndex, line) in lines.enumerated() {
            for text in line.split(separator: " ") {
                result.append(Word(id: result.count, line: lineIndex, text: String(text)))
            }
        }
        return result
    }

    var body: some View {
        let words = allWords

        VStack(spacing: 0) {
            ForEach(lines.indices, id: \.self) { lineIndex in
                HStack(spacing: fontSize * 0.26) {
                    ForEach(words.filter { $0.line == lineIndex }) { word in
                        Text(word.text)
                            .modifier(WordReveal(phase: phase, index: word.id, delay: delay))
                    }
                }
            }
        }
        .font(.system(size: fontSize, weight: .semibold, design: .serif))
        .foregroundStyle(Palette.ink)
        .fixedSize()
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(lines.joined(separator: " "))
        .accessibilityAddTraits(.isHeader)
        .accessibilityHidden(phase != .shown)
    }
}

private struct WordReveal: ViewModifier {
    let phase: RevealPhase
    let index: Int
    let delay: Double

    private var offset: CGFloat {
        switch phase {
        case .before: 18
        case .shown: 0
        case .after: -16
        }
    }

    private var springAnimation: Animation {
        switch phase {
        case .shown:
            .spring(duration: 0.75, bounce: 0.25).delay(delay + Double(index) * 0.06)
        case .before, .after:
            .easeIn(duration: 0.28).delay(Double(index) * 0.03)
        }
    }

    func body(content: Content) -> some View {
        content
            .opacity(phase == .shown ? 1 : 0)
            .blur(radius: phase == .shown ? 0 : 7)
            .offset(y: offset)
            .animation(springAnimation, value: phase)
    }
}
