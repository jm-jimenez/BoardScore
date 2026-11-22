//
//  MatchResultModel.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 21/11/2026.
//

import Foundation

public extension Domain {
    struct MatchResultModel: Sendable, Equatable {
        public let playedAt: Date
        public let participants: [Participant]

        public init(playedAt: Date, participants: [Participant]) {
            self.playedAt = playedAt
            self.participants = participants
        }
    }
}

public extension Domain.MatchResultModel {
    struct Participant: Sendable, Equatable {
        public let player: Domain.PlayerModel
        public let score: Int
        public let isWinner: Bool

        public init(player: Domain.PlayerModel, score: Int, isWinner: Bool) {
            self.player = player
            self.score = score
            self.isWinner = isWinner
        }
    }
}
