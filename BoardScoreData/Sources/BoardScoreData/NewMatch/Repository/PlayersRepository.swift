//
//  PlayersRepository.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 17/11/2026.
//

import Foundation
import SwiftData
import BoardScoreDomain

public actor DefaultPlayersRepository: ModelActor {
    public nonisolated let modelExecutor: any ModelExecutor
    public nonisolated let modelContainer: ModelContainer

    private let mapper: PlayerEntityMapperProtocol

    public init(modelContainer: ModelContainer) {
        self.init(modelContainer: modelContainer, mapper: PlayerEntityMapper())
    }

    init(modelContainer: ModelContainer, mapper: PlayerEntityMapperProtocol) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.mapper = mapper
    }
}

extension DefaultPlayersRepository: PlayersRepositoryProtocol {
    public func getPlayers() async throws -> [Domain.PlayerModel] {
        let descriptor = FetchDescriptor<PlayerEntity>(
            predicate: #Predicate { !$0.isArchived },
            sortBy: [SortDescriptor(\.name)]
        )
        return try modelContext.fetch(descriptor).map(mapper.map)
    }

    public func addPlayer(_ player: Domain.NewPlayerModel) async throws -> Domain.PlayerModel {
        let entity = PlayerEntity(name: player.name)
        modelContext.insert(entity)
        try modelContext.save()
        return mapper.map(entity)
    }
}
