import SwiftUI
import BoardScorePresentation

struct ContentView: View {
    var body: some View {
        DashboardFactory.build()
    }
}

#Preview {
    ContentView()
}
