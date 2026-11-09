//
//  GetTopWinnersModelMock.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import BoardScoreData

public extension BoardScoreData.Data.GetTopWinnersModel {
    static func mock(
        name: String = "test",
        lastGameWin: String = "test",
        wins: Int = 0,
        losses: Int = 0
    ) -> Self {
        Self(name: name,
             lastGameWin: lastGameWin,
             wins: wins,
             losses: losses)
    }
}
