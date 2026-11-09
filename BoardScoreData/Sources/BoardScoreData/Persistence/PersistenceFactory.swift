//
//  PersistenceFactory.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import SwiftData

public enum PersistenceFactory {
    public static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema(versionedSchema: BoardScoreSchemaV1.self)
        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: inMemory
        )
        return try ModelContainer(
            for: schema,
            migrationPlan: BoardScoreMigrationPlan.self,
            configurations: [configuration]
        )
    }
}
