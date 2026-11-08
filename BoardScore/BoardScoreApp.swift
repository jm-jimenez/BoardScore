import SwiftUI
import BoardScorePresentation
import BoardScoreDomain
import BoardScoreData

@main struct BoardScoreApp: App {

    private let dependencies = ModuleDependencies()

    var body: some Scene {
        WindowGroup {
            DashboardFactory.build(dependencies: dependencies)
        }
    }
}

extension BoardScoreApp {
    struct ModuleDependencies: DashboardExternalDependencies {
        func resolve() -> DashboardRepositoryProtocol {
            DefaultDashboardRepository()
        }
    }
}
