//
//  DashboardExternalDependenciesTest.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 09/11/2026.
//

import BoardScoreDomain
import BoardScoreDomainMocks
@testable import BoardScorePresentation

struct DashboardExternalDependenciesTest: AppExternalDependencies {
    func resolve() -> DashboardRepositoryProtocol {
        DashboardRepositoryMock()
    }

    func resolve() -> GamesRepositoryProtocol {
        GamesRepositoryMock()
    }

    func resolve() -> PlayersRepositoryProtocol {
        PlayersRepositoryMock()
    }

    func resolve() -> MatchesRepositoryProtocol {
        MatchesRepositoryMock()
    }

    func resolve() -> AppCoordinatorProtocol? {
        nil
    }
}
