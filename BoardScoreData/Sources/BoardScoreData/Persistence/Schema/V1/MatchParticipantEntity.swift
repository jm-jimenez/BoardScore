//
//  MatchParticipantEntity.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import Foundation
import SwiftData

extension BoardScoreSchemaV1 {
    @Model
    final class MatchParticipantEntity {
        var turnOrder: Int
        var isWinner: Bool
        var match: MatchEntity?
        var player: PlayerEntity?

        @Relationship(deleteRule: .cascade, inverse: \ScoreEntity.participant)
        var scores: [ScoreEntity] = []

        var totalScore: Int {
            scores.reduce(0) { $0 + $1.value }
        }

        init(
            match: MatchEntity,
            player: PlayerEntity,
            turnOrder: Int,
            isWinner: Bool = false
        ) {
            self.match = match
            self.player = player
            self.turnOrder = turnOrder
            self.isWinner = isWinner
        }
    }
}
