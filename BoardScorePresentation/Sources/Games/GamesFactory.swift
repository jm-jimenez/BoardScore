//
//  GamesFactory.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import SwiftUI
import BoardScoreDomain

@MainActor
struct GamesFactory {
    static func build(dependencies external: GamesExternalDependencies) -> some View {
        let dependencies = Dependency(external: external)
        let viewModel = GamesViewModel(
            getGamesUseCase: dependencies.resolve(),
            getGameStatsUseCase: dependencies.resolve(),
            statsMapper: dependencies.resolve()
        )
        return GamesView(viewModel: viewModel)
    }

    struct Dependency: GamesDependencies {
        let external: GamesExternalDependencies
    }
}

protocol GamesDependencies {
    var external: GamesExternalDependencies { get }
    func resolve() -> GetGamesUseCaseProtocol
    func resolve() -> GetGameStatsUseCaseProtocol
    func resolve() -> GameStatsMapperProtocol
}

extension GamesDependencies {
    func resolve() -> GetGamesUseCaseProtocol {
        GetGamesUseCase(repository: external.resolve())
    }

    func resolve() -> GetGameStatsUseCaseProtocol {
        GetGameStatsUseCase(repository: external.resolve())
    }

    func resolve() -> GameStatsMapperProtocol {
        GameStatsMapper()
    }
}

public protocol GamesExternalDependencies {
    func resolve() -> GamesRepositoryProtocol
    func resolve() -> MatchesRepositoryProtocol
}
