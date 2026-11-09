//
//  GetLastGamesMapper.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 06/11/2026.
//

import BoardScoreDomain

public protocol GetLastGamesMapperProtocol: Sendable {
    func map(_ games: [Data.GetLastGamesModel]) -> [Domain.GetLastGamesModel]
}

public struct GetLastGamesMapper: GetLastGamesMapperProtocol {
    public init() { }

    public func map(_ games: [Data.GetLastGamesModel]) -> [Domain.GetLastGamesModel] {
        games.map {
            Domain.GetLastGamesModel(
                name: $0.name,
                winner: $0.winner,
                date: $0.date)
        }
    }
}
