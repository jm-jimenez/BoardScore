//
//  DashboardRepositoryTests.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 18/10/2026.
//

import Foundation
import Testing

@testable import BoardScoreData

struct DashboardRepositoryTests {
    let helper: PersistenceTestHelper
    let sut: DefaultDashboardRepository

    init() throws {
        helper = try PersistenceTestHelper()
        sut = DefaultDashboardRepository(modelContainer: helper.container)
    }

    @Test
    func getLastGames_EmptyStore_ShouldReturnEmpty() async throws {
        let result = try await sut.getLastGames()
        #expect(result.isEmpty)
    }

    @Test
    func getLastGames_ShouldBeSortedByDateDescending() async throws {
        let dominion = helper.makeGame("Dominion")
        let wingspan = helper.makeGame("Wingspan")
        let dani = helper.makePlayer("Dani")
        let mercedes = helper.makePlayer("Mercedes")
        let older = Date(timeIntervalSince1970: 1_000)
        let newer = Date(timeIntervalSince1970: 2_000)
        helper.makeMatch(game: dominion, playedAt: older, results: [.win(dani, [30]), .loss(mercedes, [20])])
        helper.makeMatch(game: wingspan, playedAt: newer, results: [.loss(dani, [60]), .win(mercedes, [80])])
        try helper.save()

        let result = try await sut.getLastGames()

        #expect(result.map(\.name) == ["Wingspan", "Dominion"])
        #expect(result.map(\.winner) == ["Mercedes", "Dani"])
        #expect(result.map(\.date) == [newer, older])
    }

    @Test
    func getLastGames_ShouldRespectLimit() async throws {
        let game = helper.makeGame("Azul")
        let player = helper.makePlayer("Dani")
        for index in 0 ..< (DefaultDashboardRepository.C.lastGamesLimit + 3) {
            helper.makeMatch(
                game: game,
                playedAt: Date(timeIntervalSince1970: TimeInterval(index)),
                results: [.win(player, [index])]
            )
        }
        try helper.save()

        let result = try await sut.getLastGames()

        #expect(result.count == DefaultDashboardRepository.C.lastGamesLimit)
    }

    @Test
    func getLastGames_SharedWin_ShouldJoinWinnersInTurnOrder() async throws {
        let game = helper.makeGame("Catan")
        let alice = helper.makePlayer("Alice")
        let bob = helper.makePlayer("Bob")
        helper.makeMatch(game: game, playedAt: .now, results: [.win(bob, [10]), .win(alice, [10])])
        try helper.save()

        let result = try await sut.getLastGames()

        #expect(result.first?.winner == "Bob, Alice")
    }

    @Test
    func getTopWinners_EmptyStore_ShouldReturnEmpty() async throws {
        let result = try await sut.getTopWinners()
        #expect(result.isEmpty)
    }

    @Test
    func getTopWinners_ShouldCountWinsLossesAndLastWin() async throws {
        let wingspan = helper.makeGame("Wingspan")
        let alquimistas = helper.makeGame("Alquimistas")
        let mercedes = helper.makePlayer("Mercedes")
        let mario = helper.makePlayer("M@rio")
        let nobody = helper.makePlayer("Nobody")
        helper.makeMatch(
            game: wingspan,
            playedAt: Date(timeIntervalSince1970: 1_000),
            results: [.win(mercedes, [80]), .loss(mario, [60]), .loss(nobody, [1])]
        )
        helper.makeMatch(
            game: alquimistas,
            playedAt: Date(timeIntervalSince1970: 3_000),
            results: [.win(mercedes, [50]), .loss(mario, [40])]
        )
        helper.makeMatch(
            game: wingspan,
            playedAt: Date(timeIntervalSince1970: 2_000),
            results: [.loss(mercedes, [40]), .win(mario, [90])]
        )
        try helper.save()

        let result = try await sut.getTopWinners()

        #expect(result.map(\.name) == ["Mercedes", "M@rio"])
        #expect(result[0].wins == 2)
        #expect(result[0].losses == 1)
        #expect(result[0].lastGameWin == "Alquimistas")
        #expect(result[1].wins == 1)
        #expect(result[1].losses == 2)
        #expect(result[1].lastGameWin == "Wingspan")
    }

    @Test
    func getTopWinners_TiedWins_ShouldSortByFewerLossesThenName() async throws {
        let game = helper.makeGame("Azul")
        let alice = helper.makePlayer("Alice")
        let bob = helper.makePlayer("Bob")
        let carol = helper.makePlayer("Carol")
        let date = Date(timeIntervalSince1970: 1_000)
        helper.makeMatch(game: game, playedAt: date, results: [.win(carol, [10]), .loss(alice, [5])])
        helper.makeMatch(game: game, playedAt: date, results: [.win(bob, [10]), .loss(carol, [5])])
        helper.makeMatch(game: game, playedAt: date, results: [.win(alice, [10])])
        try helper.save()

        let result = try await sut.getTopWinners()

        #expect(result.map(\.name) == ["Bob", "Alice", "Carol"])
    }

    @Test
    func getTopWinners_ShouldExcludeArchivedPlayers() async throws {
        let game = helper.makeGame("Catan")
        let active = helper.makePlayer("Active")
        let archived = helper.makePlayer("Archived", isArchived: true)
        helper.makeMatch(game: game, playedAt: .now, results: [.win(archived, [10]), .loss(active, [5])])
        helper.makeMatch(game: game, playedAt: .now, results: [.win(active, [10])])
        try helper.save()

        let result = try await sut.getTopWinners()

        #expect(result.map(\.name) == ["Active"])
    }

    @Test
    func getTopWinners_ShouldRespectLimit() async throws {
        let game = helper.makeGame("Azul")
        for index in 0..<(DefaultDashboardRepository.C.topWinnersLimit + 2) {
            let player = helper.makePlayer("Player \(index)")
            helper.makeMatch(game: game, playedAt: .now, results: [.win(player, [1])])
        }
        try helper.save()

        let result = try await sut.getTopWinners()

        #expect(result.count == DefaultDashboardRepository.C.topWinnersLimit)
    }
}
