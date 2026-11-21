//
//  NewMatchFactory.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import SwiftUI
import BoardScoreDomain

@MainActor
public struct NewMatchFactory {
    static func build(
        dependencies external: NewMatchExternalDependencies,
        onFinish: @escaping @MainActor () -> Void
    ) -> some View {
        let dependencies = Dependency(external: external)
        let viewModel = NewMatchViewModel(
            getGamesUseCase: dependencies.resolve(),
            getPlayersUseCase: dependencies.resolve(),
            addPlayerUseCase: dependencies.resolve(),
            addMatchUseCase: dependencies.resolve(),
            resolveWinnersUseCase: dependencies.resolve(),
            router: dependencies.external.resolve(),
            onFinish: onFinish
        )
        return NewMatchView(viewModel: viewModel)
    }

    struct Dependency: NewMatchDependencies {
        let external: NewMatchExternalDependencies
    }
}

protocol NewMatchDependencies {
    var external: NewMatchExternalDependencies { get }
    func resolve() -> GetGamesUseCaseProtocol
    func resolve() -> GetPlayersUseCaseProtocol
    func resolve() -> AddPlayerUseCaseProtocol
    func resolve() -> AddMatchUseCaseProtocol
    func resolve() -> ResolveWinnersUseCaseProtocol
}

extension NewMatchDependencies {
    func resolve() -> GetGamesUseCaseProtocol {
        GetGamesUseCase(repository: external.resolve())
    }

    func resolve() -> GetPlayersUseCaseProtocol {
        GetPlayersUseCase(repository: external.resolve())
    }

    func resolve() -> AddPlayerUseCaseProtocol {
        AddPlayerUseCase(repository: external.resolve())
    }

    func resolve() -> AddMatchUseCaseProtocol {
        AddMatchUseCase(repository: external.resolve())
    }

    func resolve() -> ResolveWinnersUseCaseProtocol {
        ResolveWinnersUseCase()
    }
}

public protocol NewMatchExternalDependencies {
    func resolve() -> GamesRepositoryProtocol
    func resolve() -> PlayersRepositoryProtocol
    func resolve() -> MatchesRepositoryProtocol
    func resolve() -> AppCoordinatorProtocol?
}
