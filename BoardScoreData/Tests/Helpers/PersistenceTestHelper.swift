//
//  PersistenceTestHelper.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import Foundation
import SwiftData

@testable import BoardScoreData

struct MatchResult {
    let player: PlayerEntity
    let scores: [Int]
    let isWinner: Bool

    static func win(_ player: PlayerEntity, _ scores: [Int]) -> MatchResult {
        MatchResult(player: player, scores: scores, isWinner: true)
    }

    static func loss(_ player: PlayerEntity, _ scores: [Int]) -> MatchResult {
        MatchResult(player: player, scores: scores, isWinner: false)
    }
}

struct PersistenceTestHelper {
    let container: ModelContainer
    let context: ModelContext

    init() throws {
        container = try PersistenceFactory.makeContainer(inMemory: true)
        context = ModelContext(container)
    }

    @discardableResult
    func makeGame(
        _ name: String,
        winCondition: WinCondition = .highestScore,
        scoreables: [String] = ["Points"]
    ) -> GameEntity {
        let game = GameEntity(name: name, winCondition: winCondition)
        context.insert(game)
        for (index, scoreable) in scoreables.enumerated() {
            context.insert(ScoreableEntity(name: scoreable, sortOrder: index, game: game))
        }
        return game
    }

    @discardableResult
    func makePlayer(_ name: String, isArchived: Bool = false) -> PlayerEntity {
        let player = PlayerEntity(name: name, isArchived: isArchived)
        context.insert(player)
        return player
    }

    @discardableResult
    func makeMatch(
        game: GameEntity,
        playedAt: Date,
        results: [MatchResult]
    ) -> MatchEntity {
        let match = MatchEntity(game: game, playedAt: playedAt)
        context.insert(match)
        let scoreables = game.scoreables.sorted { $0.sortOrder < $1.sortOrder }
        for (turnOrder, result) in results.enumerated() {
            let participant = MatchParticipantEntity(
                match: match,
                player: result.player,
                turnOrder: turnOrder,
                isWinner: result.isWinner
            )
            context.insert(participant)
            for (scoreable, value) in zip(scoreables, result.scores) {
                context.insert(ScoreEntity(value: value, participant: participant, scoreable: scoreable))
            }
        }
        return match
    }

    func save() throws {
        try context.save()
    }

    func count<T: PersistentModel>(_ type: T.Type) throws -> Int {
        try context.fetchCount(FetchDescriptor<T>())
    }
}
