//
//  GetLastGamesMapper.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 06/11/2026.
//

import BoardScoreData

public protocol GetLastGamesMapperProtocol: Sendable {
    func map(_ games: [Data.GetLastGamesModel]) -> [Domain.GetLastGamesModel]
}

struct GetLastGamesMapper: GetLastGamesMapperProtocol {
    func map(_ games: [Data.GetLastGamesModel]) -> [Domain.GetLastGamesModel] {
        return []
    }
}
