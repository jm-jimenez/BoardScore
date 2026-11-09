//
//  GetTopWinnersModelMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 09/11/2026.
//

import BoardScoreDomain

public extension Domain.GetTopWinnersModel {
    static func mock(
        name: String = "Test",
        lastGameWin: String = "Test",
        wins: Int = 0,
        losses: Int = 0
    ) -> Self {
        Self(name: name,
             lastGameWin: lastGameWin,
             wins: wins,
             losses: losses
        )
    }
}
