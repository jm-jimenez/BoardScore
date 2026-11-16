//
//  GetPlayersUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

public protocol GetPlayersUseCaseProtocol: Sendable {
    func callAsFunction() async throws -> [Domain.PlayerModel]
}

public struct GetPlayersUseCase {
    private let repository: PlayersRepositoryProtocol

    public init(repository: PlayersRepositoryProtocol) {
        self.repository = repository
    }
}

extension GetPlayersUseCase: GetPlayersUseCaseProtocol {
    public func callAsFunction() async throws -> [Domain.PlayerModel] {
        try await repository.getPlayers()
    }
}
