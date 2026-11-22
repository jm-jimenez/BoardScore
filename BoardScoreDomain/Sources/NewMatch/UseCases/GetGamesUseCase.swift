//
//  GetGamesUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

public protocol GetGamesUseCaseProtocol: Sendable {
    func callAsFunction() async throws -> [Domain.GameModel]
}

public struct GetGamesUseCase {
    private let repository: GamesRepositoryProtocol

    public init(repository: GamesRepositoryProtocol) {
        self.repository = repository
    }
}

extension GetGamesUseCase: GetGamesUseCaseProtocol {
    public func callAsFunction() async throws -> [Domain.GameModel] {
        try await repository.getGames()
    }
}
