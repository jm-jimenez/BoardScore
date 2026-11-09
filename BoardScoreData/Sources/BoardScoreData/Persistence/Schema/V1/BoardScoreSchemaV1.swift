//
//  BoardScoreSchemaV1.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import SwiftData

enum BoardScoreSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            GameEntity.self,
            ScoreableEntity.self,
            PlayerEntity.self,
            MatchEntity.self,
            MatchParticipantEntity.self,
            ScoreEntity.self
        ]
    }
}
