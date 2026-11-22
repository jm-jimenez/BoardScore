//
//  AddGameUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

public protocol AddGameUseCaseProtocol: Sendable {
    func callAsFunction(_ game: Domain.NewGameModel) async throws -> Domain.GameModel
}

public struct AddGameUseCase {
    private let repository: GamesRepositoryProtocol

    public init(repository: GamesRepositoryProtocol) {
        self.repository = repository
    }
}

extension AddGameUseCase: AddGameUseCaseProtocol {
    public func callAsFunction(_ game: Domain.NewGameModel) async throws -> Domain.GameModel {
        try await repository.addGame(game)
    }
}
