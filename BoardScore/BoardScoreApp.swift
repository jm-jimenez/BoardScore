import SwiftUI
import BoardScorePresentation

@main struct BoardScoreApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardFactory.build()
        }
    }
}
