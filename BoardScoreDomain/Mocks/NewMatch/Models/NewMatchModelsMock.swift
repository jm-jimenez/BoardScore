//
//  NewMatchModelsMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import BoardScoreDomain

public extension Domain.ScoreableModel {
    static func mock(id: UUID = UUID(), name: String = "Points") -> Self {
        Self(id: id, name: name)
    }
}

public extension Domain.GameModel {
    static func mock(
        id: UUID = UUID(),
        name: String = "Wingspan",
        winCondition: Domain.WinCondition = .highestScore,
        scoreables: [Domain.ScoreableModel] = [.mock(name: "Birds"), .mock(name: "Eggs")]
    ) -> Self {
        Self(id: id, name: name, winCondition: winCondition, scoreables: scoreables)
    }
}

public extension Domain.NewGameModel {
    static func mock(
        name: String = "New game",
        winCondition: Domain.WinCondition = .highestScore,
        scoreableNames: [String] = ["Points"]
    ) -> Self {
        Self(name: name, winCondition: winCondition, scoreableNames: scoreableNames)
    }
}

public extension Domain.NewPlayerModel {
    static func mock(name: String = "Lucía") -> Self {
        Self(name: name)
    }
}

public extension Domain.PlayerModel {
    static func mock(id: UUID = UUID(), name: String = "Mercedes") -> Self {
        Self(id: id, name: name)
    }
}
