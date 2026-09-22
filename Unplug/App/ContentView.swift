import SwiftUI

struct ContentView: View {
    @State private var isWindDownPresented = false

    var body: some View {
        TonightScreen {
            isWindDownPresented = true
        }
        .floatingSheet(isPresented: $isWindDownPresented) {
            WindDownSheet {
                isWindDownPresented = false
            }
        }
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
