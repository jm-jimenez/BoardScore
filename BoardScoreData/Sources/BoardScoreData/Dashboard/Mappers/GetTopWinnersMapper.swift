//
//  GetTopWinnersMapper.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import BoardScoreDomain

public protocol GetTopWinnersMapperProtocol: Sendable {
    func map(_ winners: [Data.GetTopWinnersModel]) -> [Domain.GetTopWinnersModel]
}

public struct GetTopWinnersMapper: GetTopWinnersMapperProtocol {
    public init() { }

    public func map(_ winners: [Data.GetTopWinnersModel]) -> [Domain.GetTopWinnersModel] {
        winners.map {
            Domain.GetTopWinnersModel(
                name: $0.name,
                lastGameWin: $0.lastGameWin,
                wins: $0.wins,
                losses: $0.losses)
        }
    }
}
