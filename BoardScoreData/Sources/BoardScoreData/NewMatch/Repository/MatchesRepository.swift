//
//  MatchesRepository.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 17/11/2026.
//

import Foundation
import SwiftData
import BoardScoreDomain

public actor DefaultMatchesRepository: ModelActor {
    public nonisolated let modelExecutor: any ModelExecutor
    public nonisolated let modelContainer: ModelContainer

    public init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
    }
}

extension DefaultMatchesRepository: MatchesRepositoryProtocol {
    public func addMatch(_ match: Domain.NewMatchModel) async throws {
        let game = try game(for: match.game)
        let players = try players(for: match.participants.map(\.player))
        let scoreables = Dictionary(uniqueKeysWithValues: game.scoreables.map { ($0.id, $0) })

        let entity = MatchEntity(
            game: game,
            playedAt: match.playedAt,
            duration: match.durationMinutes.map { TimeInterval($0 * 60) },
            isWinnerManuallySelected: match.isWinnerManuallySelected
        )
        modelContext.insert(entity)

        for participant in match.participants {
            guard let player = players[participant.player.id] else {
                throw MatchesRepositoryError.playerNotFound
            }

            let participantEntity = MatchParticipantEntity(
                match: entity,
                player: player,
                turnOrder: participant.turnOrder,
                isWinner: participant.isWinner
            )
            modelContext.insert(participantEntity)

            for (scoreable, value) in participant.scores {
                guard let scoreableEntity = scoreables[scoreable.id] else {
                    throw MatchesRepositoryError.scoreableNotFound
                }

                let score = ScoreEntity(value: value, participant: participantEntity, scoreable: scoreableEntity)
                modelContext.insert(score)
            }
        }

        try modelContext.save()
    }
}

enum MatchesRepositoryError: Error {
    case gameNotFound
    case playerNotFound
    case scoreableNotFound
}

private extension DefaultMatchesRepository {
    func game(for game: Domain.GameModel) throws -> GameEntity {
        let id = game.id
        var descriptor = FetchDescriptor<GameEntity>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        guard let entity = try modelContext.fetch(descriptor).first else {
            throw MatchesRepositoryError.gameNotFound
        }

        return entity
    }

    func players(for players: [Domain.PlayerModel]) throws -> [UUID: PlayerEntity] {
        let ids = players.map(\.id)
        let descriptor = FetchDescriptor<PlayerEntity>(predicate: #Predicate { ids.contains($0.id) })
        return Dictionary(uniqueKeysWithValues: try modelContext.fetch(descriptor).map { ($0.id, $0) })
    }
}
