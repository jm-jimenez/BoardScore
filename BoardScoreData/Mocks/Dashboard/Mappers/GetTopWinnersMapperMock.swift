//
//  GetTopWinnersMapperMock.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import BoardScoreDomain
import BoardScoreData

public struct GetTopWinnersMapperMock: GetTopWinnersMapperProtocol {
    public init() {}
    public func map(_ winners: [Data.GetTopWinnersModel]) -> [Domain.GetTopWinnersModel] {
        []
    }
}
