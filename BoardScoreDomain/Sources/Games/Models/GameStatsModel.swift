//
//  GameStatsModel.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 21/11/2026.
//

public extension Domain {
    struct GameStatsModel: Sendable, Equatable {
        public let timesPlayed: Int
        public let averageScore: Double?
        public let maxScores: [PlayerValue]
        public let wins: [PlayerValue]
        public let topWinners: [PlayerValue]
        public let bestWinRates: [PlayerRate]
        public let underplayedWinRates: [PlayerRate]
        public let longestWinStreaks: [PlayerValue]
        public let mostLosses: [PlayerValue]

        public init(
            timesPlayed: Int,
            averageScore: Double?,
            maxScores: [PlayerValue],
            wins: [PlayerValue],
            topWinners: [PlayerValue],
            bestWinRates: [PlayerRate],
            underplayedWinRates: [PlayerRate],
            longestWinStreaks: [PlayerValue],
            mostLosses: [PlayerValue]
        ) {
            self.timesPlayed = timesPlayed
            self.averageScore = averageScore
            self.maxScores = maxScores
            self.wins = wins
            self.topWinners = topWinners
            self.bestWinRates = bestWinRates
            self.underplayedWinRates = underplayedWinRates
            self.longestWinStreaks = longestWinStreaks
            self.mostLosses = mostLosses
        }
    }
}

public extension Domain.GameStatsModel {
    struct PlayerValue: Sendable, Equatable {
        public let player: Domain.PlayerModel
        public let value: Int

        public init(player: Domain.PlayerModel, value: Int) {
            self.player = player
            self.value = value
        }
    }

    struct PlayerRate: Sendable, Equatable {
        public let player: Domain.PlayerModel
        public let wins: Int
        public let played: Int

        public var rate: Double {
            played == 0 ? 0 : Double(wins) / Double(played)
        }

        public init(player: Domain.PlayerModel, wins: Int, played: Int) {
            self.player = player
            self.wins = wins
            self.played = played
        }
    }
}
