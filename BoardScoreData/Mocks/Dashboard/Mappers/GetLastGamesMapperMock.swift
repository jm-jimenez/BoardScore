//
//  GetLastGamesMapperMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 06/11/2026.
//

import BoardScoreDomain
import BoardScoreData

public struct GetLastGamesMapperMock: GetLastGamesMapperProtocol {
    public init() {}
    public func map(_ games: [Data.GetLastGamesModel]) -> [Domain.GetLastGamesModel] {
        []
    }
}
