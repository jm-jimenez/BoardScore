import SwiftUI
import SwiftData
import BoardScorePresentation
import BoardScoreDomain
import BoardScoreData

@main struct BoardScoreApp: App {

    private let coordinator: AppCoordinator

    init() {
        let dependencies = ModuleDependencies()
        coordinator = AppCoordinator(dependencies: dependencies)
        dependencies.coordinator = coordinator
    }

    var body: some Scene {
        WindowGroup {
            AppCoordinatorFactory.build(coordinator: coordinator)
        }
    }
}

extension BoardScoreApp {
    final class ModuleDependencies: AppExternalDependencies {
        private let modelContainer: ModelContainer

        weak var coordinator: AppCoordinatorProtocol?

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

        func resolve() -> GamesRepositoryProtocol {
            DefaultGamesRepository(modelContainer: modelContainer)
        }

        func resolve() -> PlayersRepositoryProtocol {
            MockPlayersRepository()
        }

        func resolve() -> AppCoordinatorProtocol? {
            coordinator
        }
    }
}
