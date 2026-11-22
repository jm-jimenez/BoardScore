//
//  GamesRepositoryMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import BoardScoreDomain

public struct GamesRepositoryMock: GamesRepositoryProtocol {
    private let games: [Domain.GameModel]

    public init(games: [Domain.GameModel] = []) {
        self.games = games
    }

    public func getGames() async throws -> [Domain.GameModel] {
        games
    }

    public func addGame(_ game: Domain.NewGameModel) async throws -> Domain.GameModel {
        Domain.GameModel(
            id: UUID(),
            name: game.name,
            winCondition: game.winCondition,
            scoreables: game.scoreableNames.map { Domain.ScoreableModel(id: UUID(), name: $0) }
        )
    }
}
