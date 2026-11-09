//
//  PlayerEntity.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import Foundation
import SwiftData

extension BoardScoreSchemaV1 {
    @Model
    final class PlayerEntity {
        @Attribute(.unique) var id: UUID
        var name: String
        var createdAt: Date
        var isArchived: Bool

        @Relationship(deleteRule: .nullify, inverse: \MatchParticipantEntity.player)
        var participations: [MatchParticipantEntity] = []

        init(
            id: UUID = UUID(),
            name: String,
            createdAt: Date = .now,
            isArchived: Bool = false
        ) {
            self.id = id
            self.name = name
            self.createdAt = createdAt
            self.isArchived = isArchived
        }
    }
}
