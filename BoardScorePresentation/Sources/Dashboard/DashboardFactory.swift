//
//  DashboardFactory.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI
import BoardScoreDomain

@MainActor
public struct DashboardFactory {
    static func build(dependencies external: DashboardExternalDependencies) -> some View {
        let dependencies = Dependency(external: external)
        let viewModel = DashboardViewModel(
            getLastGamesUseCase: dependencies.resolve(),
            getTopWinnersUseCase: dependencies.resolve(),
            lastGamesMapper: dependencies.resolve(),
            topWinnersMapper: dependencies.resolve(),
            router: dependencies.external.resolve()
        )
        return DashboardView(viewModel: viewModel)
    }

    struct Dependency: DashboardDependencies {
        let external: DashboardExternalDependencies
    }
}

protocol DashboardDependencies {
    var external: DashboardExternalDependencies { get }
    func resolve() -> GetLastGamesUseCaseProtocol
    func resolve() -> GetTopWinnersUseCaseProtocol
    func resolve() -> LastGamesMapperProtocol
    func resolve() -> TopWinnersMapperProtocol
}

extension DashboardDependencies {
    func resolve() -> GetLastGamesUseCaseProtocol {
        GetLastGamesUseCase(repository: external.resolve())
    }

    func resolve() -> GetTopWinnersUseCaseProtocol {
        GetTopWinnersUseCase(repository: external.resolve())
    }

    func resolve() -> LastGamesMapperProtocol {
        LastGamesMapper()
    }

    func resolve() -> TopWinnersMapperProtocol {
        TopWinnersMapper()
    }
}

public protocol DashboardExternalDependencies {
    func resolve() -> DashboardRepositoryProtocol
    func resolve() -> AppCoordinatorProtocol?
}
