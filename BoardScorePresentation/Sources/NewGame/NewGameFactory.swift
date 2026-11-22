//
//  NewGameFactory.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 16/11/2026.
//

import SwiftUI
import BoardScoreDomain

@MainActor
public struct NewGameFactory {
    static func build(
        dependencies external: NewGameExternalDependencies,
        onCreate: @escaping @MainActor (Domain.GameModel) -> Void
    ) -> some View {
        let dependencies = Dependency(external: external)
        let viewModel = NewGameViewModel(
            getGamesUseCase: dependencies.resolve(),
            addGameUseCase: dependencies.resolve(),
            router: dependencies.external.resolve(),
            onCreate: onCreate
        )
        return NewGameView(viewModel: viewModel)
    }

    struct Dependency: NewGameDependencies {
        let external: NewGameExternalDependencies
    }
}

protocol NewGameDependencies {
    var external: NewGameExternalDependencies { get }
    func resolve() -> GetGamesUseCaseProtocol
    func resolve() -> AddGameUseCaseProtocol
}

extension NewGameDependencies {
    func resolve() -> GetGamesUseCaseProtocol {
        GetGamesUseCase(repository: external.resolve())
    }

    func resolve() -> AddGameUseCaseProtocol {
        AddGameUseCase(repository: external.resolve())
    }
}

public protocol NewGameExternalDependencies {
    func resolve() -> GamesRepositoryProtocol
    func resolve() -> AppCoordinatorProtocol?
}
