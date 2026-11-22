//
//  GamesRepositoryTests.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import Testing
import BoardScoreDomain

@testable import BoardScoreData

struct GamesRepositoryTests {
    let helper: PersistenceTestHelper
    let sut: DefaultGamesRepository

    init() throws {
        helper = try PersistenceTestHelper()
        sut = DefaultGamesRepository(modelContainer: helper.container)
    }

    @Test
    func getGames_EmptyStore_ShouldReturnEmpty() async throws {
        let result = try await sut.getGames()
        #expect(result.isEmpty)
    }

    @Test
    func getGames_ShouldReturnActiveGamesSortedByName() async throws {
        helper.makeGame("Wingspan")
        helper.makeGame("Azul", winCondition: .lowestScore)
        let archived = helper.makeGame("Catan")
        archived.isArchived = true
        try helper.save()

        let result = try await sut.getGames()

        #expect(result.map(\.name) == ["Azul", "Wingspan"])
        #expect(result.first?.winCondition == .lowestScore)
    }

    @Test
    func getGames_ShouldReturnActiveScoreablesInOrder() async throws {
        let game = helper.makeGame("Wingspan", scoreables: ["Birds", "Bonus", "Eggs"])
        game.scoreables.first { $0.name == "Bonus" }?.isArchived = true
        try helper.save()

        let result = try await sut.getGames()

        #expect(result.first?.scoreables.map(\.name) == ["Birds", "Eggs"])
    }

    @Test
    func addGame_ShouldPersistGameAndScoreables() async throws {
        let newGame = Domain.NewGameModel(
            name: "Dominion",
            winCondition: .highestScore,
            scoreableNames: ["VP", "Curses"]
        )

        let created = try await sut.addGame(newGame)
        let stored = try await sut.getGames()

        #expect(created.name == "Dominion")
        #expect(created.winCondition == .highestScore)
        #expect(created.scoreables.map(\.name) == ["VP", "Curses"])
        #expect(stored == [created])
    }

    @Test
    func winCondition_ShouldMapBothWays() {
        for condition in Domain.WinCondition.allCases {
            #expect(WinCondition(condition).domain == condition)
        }
    }
}
