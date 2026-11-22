//
//  GamesModelsMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 21/11/2026.
//

import Foundation
import BoardScoreDomain

public extension Domain.MatchResultModel {
    static func mock(
        playedAt: Date = Date(timeIntervalSince1970: 1_000),
        participants: [Participant] = []
    ) -> Self {
        Self(playedAt: playedAt, participants: participants)
    }
}

public extension Domain.MatchResultModel.Participant {
    static func win(_ player: Domain.PlayerModel, _ score: Int = 0) -> Self {
        Self(player: player, score: score, isWinner: true)
    }

    static func loss(_ player: Domain.PlayerModel, _ score: Int = 0) -> Self {
        Self(player: player, score: score, isWinner: false)
    }
}

public extension Domain.GameStatsModel {
    static func mock(
        timesPlayed: Int = 4,
        averageScore: Double? = 52.5,
        maxScores: [PlayerValue] = [.init(player: .mock(name: "Mercedes"), value: 90)],
        wins: [PlayerValue] = [
            .init(player: .mock(name: "Mercedes"), value: 3),
            .init(player: .mock(name: "Dani"), value: 1)
        ],
        topWinners: [PlayerValue] = [.init(player: .mock(name: "Mercedes"), value: 3)],
        bestWinRates: [PlayerRate] = [.init(player: .mock(name: "Mercedes"), wins: 3, played: 4)],
        underplayedWinRates: [PlayerRate] = [],
        longestWinStreaks: [PlayerValue] = [.init(player: .mock(name: "Mercedes"), value: 2)],
        mostLosses: [PlayerValue] = [.init(player: .mock(name: "Dani"), value: 3)]
    ) -> Self {
        Self(
            timesPlayed: timesPlayed,
            averageScore: averageScore,
            maxScores: maxScores,
            wins: wins,
            topWinners: topWinners,
            bestWinRates: bestWinRates,
            underplayedWinRates: underplayedWinRates,
            longestWinStreaks: longestWinStreaks,
            mostLosses: mostLosses
        )
    }
}
