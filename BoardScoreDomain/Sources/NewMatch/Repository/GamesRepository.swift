//
//  GamesRepository.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

public protocol GamesRepositoryProtocol: Sendable {
    func getGames() async throws -> [Domain.GameModel]
    func addGame(_ game: Domain.NewGameModel) async throws -> Domain.GameModel
}
