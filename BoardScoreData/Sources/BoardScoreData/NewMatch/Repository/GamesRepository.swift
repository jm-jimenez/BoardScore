//
//  GamesRepository.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import SwiftData
import BoardScoreDomain

public actor DefaultGamesRepository: ModelActor {
    public nonisolated let modelExecutor: any ModelExecutor
    public nonisolated let modelContainer: ModelContainer

    private let mapper: GameEntityMapperProtocol

    public init(modelContainer: ModelContainer) {
        self.init(modelContainer: modelContainer, mapper: GameEntityMapper())
    }

    init(modelContainer: ModelContainer, mapper: GameEntityMapperProtocol) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.mapper = mapper
    }
}

extension DefaultGamesRepository: GamesRepositoryProtocol {
    public func getGames() async throws -> [Domain.GameModel] {
        let descriptor = FetchDescriptor<GameEntity>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor).map(mapper.map)
    }

    public func addGame(_ game: Domain.NewGameModel) async throws -> Domain.GameModel {
        let entity = GameEntity(name: game.name, winCondition: WinCondition(game.winCondition))
        modelContext.insert(entity)
        for (index, name) in game.scoreableNames.enumerated() {
            modelContext.insert(ScoreableEntity(name: name, sortOrder: index, game: entity))
        }
        try modelContext.save()
        return mapper.map(entity)
    }
}
