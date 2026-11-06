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
        games.map(Domain.GetLastGamesModel.init)
    }
}

extension Domain.GetLastGamesModel {
    init(domain: Data.GetLastGamesModel) {
        self.name = domain.name
        self.winner = domain.winner
        self.date = domain.date
    }
}
