//
//  AddPlayerUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 17/11/2026.
//

public protocol AddPlayerUseCaseProtocol: Sendable {
    func callAsFunction(_ player: Domain.NewPlayerModel) async throws -> Domain.PlayerModel
}

public struct AddPlayerUseCase {
    private let repository: PlayersRepositoryProtocol

    public init(repository: PlayersRepositoryProtocol) {
        self.repository = repository
    }
}

extension AddPlayerUseCase: AddPlayerUseCaseProtocol {
    public func callAsFunction(_ player: Domain.NewPlayerModel) async throws -> Domain.PlayerModel {
        try await repository.addPlayer(player)
    }
}
