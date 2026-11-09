//
//  ScoreEntity.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import Foundation
import SwiftData

extension BoardScoreSchemaV1 {
    @Model
    final class ScoreEntity {
        var value: Int
        var participant: MatchParticipantEntity?
        var scoreable: ScoreableEntity?

        init(
            value: Int,
            participant: MatchParticipantEntity,
            scoreable: ScoreableEntity
        ) {
            self.value = value
            self.participant = participant
            self.scoreable = scoreable
        }
    }
}
