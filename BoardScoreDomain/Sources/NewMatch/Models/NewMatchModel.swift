//
//  NewMatchModel.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 17/11/2026.
//

import Foundation

public extension Domain {
    struct NewMatchModel: Sendable, Equatable {
        public let game: GameModel
        public let playedAt: Date
        public let durationMinutes: Int?
        public let isWinnerManuallySelected: Bool
        public let participants: [Participant]

        public init(
            game: GameModel,
            playedAt: Date,
            durationMinutes: Int?,
            isWinnerManuallySelected: Bool,
            participants: [Participant]
        ) {
            self.game = game
            self.playedAt = playedAt
            self.durationMinutes = durationMinutes
            self.isWinnerManuallySelected = isWinnerManuallySelected
            self.participants = participants
        }
    }
}

public extension Domain.NewMatchModel {
    struct Participant: Sendable, Equatable {
        public let player: Domain.PlayerModel
        public let turnOrder: Int
        public let scores: [Domain.ScoreableModel: Int]
        public let isWinner: Bool

        public init(
            player: Domain.PlayerModel,
            turnOrder: Int,
            scores: [Domain.ScoreableModel: Int],
            isWinner: Bool
        ) {
            self.player = player
            self.turnOrder = turnOrder
            self.scores = scores
            self.isWinner = isWinner
        }
    }
}
