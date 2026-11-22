//
//  PlayersRepositoryMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import BoardScoreDomain

public struct PlayersRepositoryMock: PlayersRepositoryProtocol {
    private let players: [Domain.PlayerModel]

    public init(players: [Domain.PlayerModel] = []) {
        self.players = players
    }

    public func getPlayers() async throws -> [Domain.PlayerModel] {
        players
    }

    public func addPlayer(_ player: Domain.NewPlayerModel) async throws -> Domain.PlayerModel {
        Domain.PlayerModel(name: player.name)
    }
}
