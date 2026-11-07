//
//  GetLastGamesModelMock.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 07/11/2026.
//

import Foundation
import BoardScoreData

public extension BoardScoreData.Data.GetLastGamesModel {
    static func mock(
        name: String = "test",
        winner: String = "test",
        date: Date = Date()
    ) -> Self {
        Self(name: name,
             winner: winner,
             date: date)
    }
}
