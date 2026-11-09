import SwiftUI
import SwiftData
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
        private let modelContainer: ModelContainer

        init() {
            do {
                modelContainer = try PersistenceFactory.makeContainer()
            } catch {
                fatalError("Unable to create the SwiftData ModelContainer: \(error)")
            }
        }

        func resolve() -> DashboardRepositoryProtocol {
            DefaultDashboardRepository(modelContainer: modelContainer)
        }
    }
}
