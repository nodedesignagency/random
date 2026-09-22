import SwiftUI

extension View {
    /// Presents `content` as a floating card that springs up from the bottom edge,
    /// frosts what's behind it, and can be flicked away with a downward swipe.
    func floatingSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(FloatingSheetModifier(isPresented: isPresented, sheetContent: content))
    }
}

private struct FloatingSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let sheetContent: () -> SheetContent

    @State private var dragOffset: CGFloat = 0

    init(isPresented: Binding<Bool>, sheetContent: @escaping () -> SheetContent) {
        _isPresented = isPresented
        self.sheetContent = sheetContent
    }

    /// Top corners match the reference; bottom corners sit concentric with the display.
    private let shape = UnevenRoundedRectangle(
        topLeadingRadius: 40,
        bottomLeadingRadius: 46,
        bottomTrailingRadius: 46,
        topTrailingRadius: 40,
        style: .continuous
    )

    /// 0 while the card rests, approaching 1 as it is dragged down towards the edge.
    private var dismissProgress: CGFloat {
        min(max(dragOffset, 0) / 480, 1)
    }

    func body(content: Content) -> some View {
        content
            .overlay {
                ZStack(alignment: .bottom) {
                    if isPresented {
                        backdrop
                            .transition(.opacity)
                            .zIndex(0)

                        card
                            .transition(.move(edge: .bottom))
                            .zIndex(1)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .ignoresSafeArea(.container, edges: .bottom)
                .animation(.spring(duration: 0.6, bounce: 0.22), value: isPresented)
            }
            .onChange(of: isPresented) { _, presented in
                // A previous swipe-to-dismiss leaves the offset behind; start fresh.
                if presented { dragOffset = 0 }
            }
    }

    private var backdrop: some View {
        ZStack {
            Rectangle()
                .fill(.ultraThinMaterial)
                .environment(\.colorScheme, .dark)
            Color.black.opacity(0.28)
        }
        .ignoresSafeArea()
        .opacity(1 - Double(dismissProgress))
        .contentShape(Rectangle())
        .onTapGesture { isPresented = false }
        .accessibilityHidden(true)
    }

    private var card: some View {
        sheetContent()
            .frame(maxWidth: 460)
            .clipShape(shape)
            .overlay {
                // Glass edge: bright where the light hits the top, fading towards the bottom.
                shape.stroke(
                    LinearGradient(
                        colors: [Color.white.opacity(0.35), Color.white.opacity(0.05)],
                        startPoint: .top,
                        endPoint: .bottom
                    ),
                    lineWidth: 1
                )
            }
            .compositingGroup()
            .shadow(color: Color.black.opacity(0.3), radius: 40, y: 18)
            .scaleEffect(1 - 0.05 * dismissProgress, anchor: .bottom)
            .gesture(dragGesture)
            .padding(.horizontal, 10)
            .padding(.bottom, 10)
            .offset(y: dragOffset)
            .accessibilityAddTraits(.isModal)
            .accessibilityAction(.escape) { isPresented = false }
    }

    private var dragGesture: some Gesture {
        // Global space so the moving card doesn't feed back into its own translation.
        DragGesture(minimumDistance: 6, coordinateSpace: .global)
            .onChanged { value in
                let dy = value.translation.height
                dragOffset = dy >= 0 ? dy : -rubberBand(-dy)
            }
            .onEnded { value in
                let dy = value.translation.height
                let projected = value.predictedEndTranslation.height
                if dy > 130 || projected > 320 {
                    // The removal transition picks up from wherever the finger left the card.
                    isPresented = false
                } else {
                    withAnimation(.spring(duration: 0.5, bounce: 0.35)) {
                        dragOffset = 0
                    }
                }
            }
    }

    /// Resistance when pulling the card the wrong way: moves less the further you pull.
    private func rubberBand(_ distance: CGFloat, limit: CGFloat = 48) -> CGFloat {
        limit * (1 - 1 / (distance / limit * 0.55 + 1))
    }
}
