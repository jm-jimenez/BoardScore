//
//  MatchEntity.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import Foundation
import SwiftData

extension BoardScoreSchemaV1 {
    @Model
    final class MatchEntity {
        #Index<MatchEntity>([\.playedAt])

        @Attribute(.unique) var id: UUID
        var playedAt: Date
        var duration: TimeInterval?
        var isWinnerManuallySelected: Bool
        var game: GameEntity?

        @Relationship(deleteRule: .cascade, inverse: \MatchParticipantEntity.match)
        var participants: [MatchParticipantEntity] = []

        var winners: [MatchParticipantEntity] {
            participants
                .filter(\.isWinner)
                .sorted { $0.turnOrder < $1.turnOrder }
        }

        init(
            id: UUID = UUID(),
            game: GameEntity,
            playedAt: Date = .now,
            duration: TimeInterval? = nil,
            isWinnerManuallySelected: Bool = false
        ) {
            self.id = id
            self.game = game
            self.playedAt = playedAt
            self.duration = duration
            self.isWinnerManuallySelected = isWinnerManuallySelected
        }
    }
}
