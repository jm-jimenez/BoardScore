//
//  BoardScoreMigrationPlan.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import SwiftData

enum BoardScoreMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [BoardScoreSchemaV1.self]
    }

    static var stages: [MigrationStage] {
        []
    }
}
