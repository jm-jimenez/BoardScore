//
//  PersistenceTests.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import Foundation
import SwiftData
import Testing

@testable import BoardScoreData

struct PersistenceTests {
    let helper: PersistenceTestHelper

    init() throws {
        helper = try PersistenceTestHelper()
    }

    @Test
    func makeContainer_ShouldUseVersionedSchema() throws {
        let entities = helper.container.schema.entities.map(\.name).sorted()
        #expect(entities == [
            "GameEntity",
            "MatchEntity",
            "MatchParticipantEntity",
            "PlayerEntity",
            "ScoreEntity",
            "ScoreableEntity"
        ])
        #expect(BoardScoreMigrationPlan.schemas.count == 1)
        #expect(BoardScoreMigrationPlan.stages.isEmpty)
    }

    @Test
    func game_ShouldStoreWinConditionAsRawValue() throws {
        let game = helper.makeGame("Golf", winCondition: .lowestScore)
        #expect(game.winCondition == .lowestScore)
        #expect(game.winConditionRaw == "lowestScore")

        game.winCondition = .highestScore
        #expect(game.winConditionRaw == "highestScore")

        game.winConditionRaw = "unknown"
        #expect(game.winCondition == .highestScore)
    }

    @Test
    func participant_TotalScore_ShouldSumAllScores() throws {
        let game = helper.makeGame("Wingspan", scoreables: ["Birds", "Bonus", "Eggs"])
        let player = helper.makePlayer("Mercedes")
        let match = helper.makeMatch(
            game: game,
            playedAt: .now,
            results: [.win(player, [40, 10, -3])]
        )
        try helper.save()

        #expect(match.participants.first?.totalScore == 47)
        #expect(match.winners.first?.player?.name == "Mercedes")
        #expect(game.scoreables.count == 3)
    }

    @Test
    func deleteMatch_ShouldCascadeParticipantsAndScores() throws {
        let game = helper.makeGame("Dominion", scoreables: ["VP", "Curses"])
        let alice = helper.makePlayer("Alice")
        let bob = helper.makePlayer("Bob")
        let match = helper.makeMatch(
            game: game,
            playedAt: .now,
            results: [.win(alice, [30, -1]), .loss(bob, [20, 0])]
        )
        try helper.save()
        #expect(try helper.count(MatchParticipantEntity.self) == 2)
        #expect(try helper.count(ScoreEntity.self) == 4)

        helper.context.delete(match)
        try helper.save()

        #expect(try helper.count(MatchEntity.self) == 0)
        #expect(try helper.count(MatchParticipantEntity.self) == 0)
        #expect(try helper.count(ScoreEntity.self) == 0)
        #expect(try helper.count(PlayerEntity.self) == 2)
        #expect(try helper.count(GameEntity.self) == 1)
        #expect(try helper.count(ScoreableEntity.self) == 2)
    }

    @Test
    func deleteGameWithMatches_ShouldNullifyMatchGame() throws {
        let game = helper.makeGame("Catan")
        let player = helper.makePlayer("Alice")
        let match = helper.makeMatch(game: game, playedAt: .now, results: [.win(player, [10])])
        try helper.save()

        helper.context.delete(game)
        try helper.save()

        #expect(try helper.count(MatchEntity.self) == 1)
        #expect(match.game == nil)
        #expect(match.participants.first?.scores.first?.scoreable == nil)
    }

    @Test
    func deleteGameWithoutMatches_ShouldCascadeScoreables() throws {
        let game = helper.makeGame("Azul", scoreables: ["Rows", "Columns"])
        try helper.save()

        helper.context.delete(game)
        try helper.save()

        #expect(try helper.count(GameEntity.self) == 0)
        #expect(try helper.count(ScoreableEntity.self) == 0)
    }

    @Test
    func deletePlayerWithMatches_ShouldNullifyParticipantPlayer() throws {
        let game = helper.makeGame("Catan")
        let player = helper.makePlayer("Alice")
        let match = helper.makeMatch(game: game, playedAt: .now, results: [.win(player, [10])])
        try helper.save()

        helper.context.delete(player)
        try helper.save()

        #expect(try helper.count(MatchParticipantEntity.self) == 1)
        #expect(match.participants.first?.player == nil)
    }
}
