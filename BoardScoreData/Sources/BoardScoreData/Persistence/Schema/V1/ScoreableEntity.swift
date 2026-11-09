//
//  ScoreableEntity.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import Foundation
import SwiftData

extension BoardScoreSchemaV1 {
    @Model
    final class ScoreableEntity {
        @Attribute(.unique) var id: UUID
        var name: String
        var sortOrder: Int
        var isArchived: Bool
        var game: GameEntity?

        @Relationship(deleteRule: .nullify, inverse: \ScoreEntity.scoreable)
        var scores: [ScoreEntity] = []

        init(
            id: UUID = UUID(),
            name: String,
            sortOrder: Int,
            game: GameEntity,
            isArchived: Bool = false
        ) {
            self.id = id
            self.name = name
            self.sortOrder = sortOrder
            self.game = game
            self.isArchived = isArchived
        }
    }
}
