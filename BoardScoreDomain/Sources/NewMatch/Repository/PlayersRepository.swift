//
//  PlayersRepository.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

public protocol PlayersRepositoryProtocol: Sendable {
    func getPlayers() async throws -> [Domain.PlayerModel]
}
