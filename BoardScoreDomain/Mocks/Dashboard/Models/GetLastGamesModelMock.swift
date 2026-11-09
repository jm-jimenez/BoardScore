//
//  GetLastGamesModelMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 27/10/2026.
//

import Foundation
import BoardScoreDomain

public extension Domain.GetLastGamesModel {
    static func mock(
        name: String = "Test",
        winner: String = "Test",
        date: Date = Date()
    ) -> Self {
        Self(name: name,
             winner: winner,
             date: date
        )
    }
}
