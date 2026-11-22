//
//  MatchesRepositoryTests.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 17/11/2026.
//

import Foundation
import Testing
import SwiftData
import BoardScoreDomain

@testable import BoardScoreData

struct MatchesRepositoryTests {
    let helper: PersistenceTestHelper
    let sut: DefaultMatchesRepository

    init() throws {
        helper = try PersistenceTestHelper()
        sut = DefaultMatchesRepository(modelContainer: helper.container)
    }

    @Test
    func addMatch_ShouldPersistMatchParticipantsAndScores() async throws {
        let fixture = try makeFixture()
        let birds = fixture.game.scoreables[0]
        let eggs = fixture.game.scoreables[1]
        let playedAt = Date(timeIntervalSince1970: 1_000)
        let match = Domain.NewMatchModel(
            game: fixture.game,
            playedAt: playedAt,
            durationMinutes: 45,
            isWinnerManuallySelected: true,
            participants: [
                participant(fixture.dani, turnOrder: 0, scores: [birds: 20, eggs: 3]),
                participant(fixture.mercedes, turnOrder: 1, scores: [birds: 30, eggs: -2], isWinner: true)
            ]
        )

        try await sut.addMatch(match)

        let matches = try helper.context.fetch(FetchDescriptor<MatchEntity>())
        let saved = try #require(matches.first)
        let participants = saved.participants.sorted { $0.turnOrder < $1.turnOrder }
        #expect(matches.count == 1)
        #expect(saved.game?.id == fixture.game.id)
        #expect(saved.playedAt == playedAt)
        #expect(saved.duration == 2_700)
        #expect(saved.isWinnerManuallySelected)
        #expect(participants.map { $0.player?.name } == ["Dani", "Mercedes"])
        #expect(participants.map(\.totalScore) == [23, 28])
        #expect(saved.winners.map { $0.player?.name } == ["Mercedes"])
        #expect(try helper.count(ScoreEntity.self) == 4)
    }

    @Test
    func addMatch_WithoutDuration_ShouldPersistNilDuration() async throws {
        let fixture = try makeFixture()

        try await sut.addMatch(match(fixture.game, [participant(fixture.mercedes, turnOrder: 0, isWinner: true)]))

        let saved = try helper.context.fetch(FetchDescriptor<MatchEntity>()).first
        #expect(saved?.duration == nil)
        #expect(saved?.isWinnerManuallySelected == false)
    }

    @Test
    func addMatch_ShouldBeVisibleToDashboard() async throws {
        let fixture = try makeFixture()
        let dashboard = DefaultDashboardRepository(modelContainer: helper.container)

        try await sut.addMatch(match(fixture.game, [
            participant(fixture.mercedes, turnOrder: 0, isWinner: true),
            participant(fixture.dani, turnOrder: 1)
        ]))

        let lastGames = try await dashboard.getLastGames()
        let topWinners = try await dashboard.getTopWinners()
        #expect(lastGames.map(\.name) == ["Wingspan"])
        #expect(lastGames.map(\.winner) == ["Mercedes"])
        #expect(topWinners.map(\.name) == ["Mercedes"])
    }

    @Test
    func addMatch_UnknownGame_ShouldThrowAndNotPersist() async throws {
        await #expect(throws: MatchesRepositoryError.gameNotFound) {
            let unknown = Domain.GameModel(name: "Unknown", winCondition: .highestScore, scoreables: [])
            try await sut.addMatch(match(unknown, []))
        }
        #expect(try helper.count(MatchEntity.self) == 0)
    }

    @Test
    func addMatch_UnknownPlayer_ShouldThrow() async throws {
        let fixture = try makeFixture()
        let unknown = Domain.PlayerModel(name: "Unknown")

        await #expect(throws: MatchesRepositoryError.playerNotFound) {
            try await sut.addMatch(match(fixture.game, [participant(unknown, turnOrder: 0)]))
        }
    }

    @Test
    func addMatch_UnknownScoreable_ShouldThrow() async throws {
        let fixture = try makeFixture()
        let unknown = Domain.ScoreableModel(name: "Unknown")

        await #expect(throws: MatchesRepositoryError.scoreableNotFound) {
            try await sut.addMatch(match(fixture.game, [
                participant(fixture.mercedes, turnOrder: 0, scores: [unknown: 10])
            ]))
        }
    }

    @Test
    func getMatches_EmptyStore_ShouldReturnEmpty() async throws {
        let game = Domain.GameModel(name: "Azul", winCondition: .highestScore, scoreables: [])

        let result = try await sut.getMatches(for: game)
        #expect(result.isEmpty)
    }

    @Test
    func getMatches_ShouldFilterByGameAndSortByDate() async throws {
        let azul = helper.makeGame("Azul")
        let catan = helper.makeGame("Catan")
        let dani = helper.makePlayer("Dani")
        let older = Date(timeIntervalSince1970: 1_000)
        let newer = Date(timeIntervalSince1970: 2_000)
        helper.makeMatch(game: azul, playedAt: newer, results: [.win(dani, [20])])
        helper.makeMatch(game: catan, playedAt: older, results: [.win(dani, [5])])
        helper.makeMatch(game: azul, playedAt: older, results: [.loss(dani, [10])])
        try helper.save()

        let result = try await sut.getMatches(for: domainGame(azul))

        #expect(result.map(\.playedAt) == [older, newer])
        #expect(result.map { $0.participants.map(\.score) } == [[10], [20]])
    }

    @Test
    func getMatches_ShouldSumScoresKeepTurnOrderAndMarkWinners() async throws {
        let game = helper.makeGame("Wingspan", scoreables: ["Birds", "Eggs"])
        let mercedes = helper.makePlayer("Mercedes")
        let dani = helper.makePlayer("Dani")
        helper.makeMatch(game: game, playedAt: .now, results: [.loss(dani, [30, 5]), .win(mercedes, [40, 12])])
        try helper.save()

        let result = try await sut.getMatches(for: domainGame(game))

        #expect(result.first?.participants == [
            Domain.MatchResultModel.Participant(
                player: Domain.PlayerModel(id: dani.id, name: "Dani"),
                score: 35,
                isWinner: false
            ),
            Domain.MatchResultModel.Participant(
                player: Domain.PlayerModel(id: mercedes.id, name: "Mercedes"),
                score: 52,
                isWinner: true
            )
        ])
    }

    @Test
    func getMatches_ShouldIgnoreParticipantsWithoutPlayer() async throws {
        let game = helper.makeGame("Azul")
        let dani = helper.makePlayer("Dani")
        let removed = helper.makePlayer("Removed")
        helper.makeMatch(game: game, playedAt: .now, results: [.win(removed, [50]), .loss(dani, [10])])
        try helper.save()
        helper.context.delete(removed)
        try helper.save()

        let result = try await sut.getMatches(for: domainGame(game))

        #expect(result.first?.participants.map(\.player.name) == ["Dani"])
    }
}

private extension MatchesRepositoryTests {
    struct Fixture {
        let game: Domain.GameModel
        let mercedes: Domain.PlayerModel
        let dani: Domain.PlayerModel
    }

    func makeFixture() throws -> Fixture {
        let game = helper.makeGame("Wingspan", scoreables: ["Birds", "Eggs"])
        let mercedes = helper.makePlayer("Mercedes")
        let dani = helper.makePlayer("Dani")
        try helper.save()

        let scoreables = game.scoreables
            .sorted { $0.sortOrder < $1.sortOrder }
            .map { Domain.ScoreableModel(id: $0.id, name: $0.name) }
        return Fixture(
            game: Domain.GameModel(
                id: game.id,
                name: game.name,
                winCondition: .highestScore,
                scoreables: scoreables
            ),
            mercedes: Domain.PlayerModel(
                id: mercedes.id,
                name: mercedes.name
            ),
            dani: Domain.PlayerModel(
                id: dani.id,
                name: dani.name
            )
        )
    }

    func match(_ game: Domain.GameModel, _ participants: [Domain.NewMatchModel.Participant]) -> Domain.NewMatchModel {
        Domain.NewMatchModel(
            game: game,
            playedAt: .now,
            durationMinutes: nil,
            isWinnerManuallySelected: false,
            participants: participants
        )
    }

    func participant(
        _ player: Domain.PlayerModel,
        turnOrder: Int,
        scores: [Domain.ScoreableModel: Int] = [:],
        isWinner: Bool = false
    ) -> Domain.NewMatchModel.Participant {
        Domain.NewMatchModel.Participant(
            player: player,
            turnOrder: turnOrder,
            scores: scores,
            isWinner: isWinner
        )
    }

    func domainGame(_ entity: GameEntity) -> Domain.GameModel {
        Domain.GameModel(
            id: entity.id,
            name: entity.name,
            winCondition: .highestScore,
            scoreables: []
        )
    }
}
