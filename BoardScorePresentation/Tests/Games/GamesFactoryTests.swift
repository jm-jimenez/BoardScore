//
//  GamesFactoryTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import Testing
import BoardScoreDomain
@testable import BoardScorePresentation

@MainActor
struct GamesFactoryTests {
    let dependencies = GamesFactory.Dependency(external: DashboardExternalDependenciesTest())

    @Test
    func gamesFactory_ShouldBuildView() {
        let view = GamesFactory.build(dependencies: DashboardExternalDependenciesTest())
        #expect(view is GamesView<GamesViewModel>)
    }

    @Test
    func dependencies_ShouldResolveEveryCollaborator() {
        let getGames: GetGamesUseCaseProtocol = dependencies.resolve()
        let getGameStats: GetGameStatsUseCaseProtocol = dependencies.resolve()
        let mapper: GameStatsMapperProtocol = dependencies.resolve()

        #expect(getGames is GetGamesUseCase)
        #expect(getGameStats is GetGameStatsUseCase)
        #expect(mapper is GameStatsMapper)
    }
}
