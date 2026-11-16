//
//  MockPlayersRepository.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import BoardScoreDomain

public struct MockPlayersRepository: PlayersRepositoryProtocol {
    static let players: [Domain.PlayerModel] = ["Mercedes", "Dani", "M@rio", "Lucía"].map {
        Domain.PlayerModel(id: UUID(), name: $0)
    }

    public init() {}

    public func getPlayers() async throws -> [Domain.PlayerModel] {
        Self.players
    }
}
