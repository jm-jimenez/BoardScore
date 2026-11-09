//
//  GameEntity.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import Foundation
import SwiftData

extension BoardScoreSchemaV1 {
    @Model
    final class GameEntity {
        @Attribute(.unique) var id: UUID
        var name: String
        var winConditionRaw: String
        var createdAt: Date
        var isArchived: Bool

        @Relationship(deleteRule: .cascade, inverse: \ScoreableEntity.game)
        var scoreables: [ScoreableEntity] = []

        @Relationship(deleteRule: .nullify, inverse: \MatchEntity.game)
        var matches: [MatchEntity] = []

        var winCondition: WinCondition {
            get { WinCondition(rawValue: winConditionRaw) ?? .highestScore }
            set { winConditionRaw = newValue.rawValue }
        }

        init(
            id: UUID = UUID(),
            name: String,
            winCondition: WinCondition = .highestScore,
            createdAt: Date = .now,
            isArchived: Bool = false
        ) {
            self.id = id
            self.name = name
            self.winConditionRaw = winCondition.rawValue
            self.createdAt = createdAt
            self.isArchived = isArchived
        }
    }
}
