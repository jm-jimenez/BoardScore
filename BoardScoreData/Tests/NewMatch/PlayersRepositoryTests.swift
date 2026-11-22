//
//  PlayersRepositoryTests.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 17/11/2026.
//

import Foundation
import Testing
import BoardScoreDomain

@testable import BoardScoreData

struct PlayersRepositoryTests {
    let helper: PersistenceTestHelper
    let sut: DefaultPlayersRepository

    init() throws {
        helper = try PersistenceTestHelper()
        sut = DefaultPlayersRepository(modelContainer: helper.container)
    }

    @Test
    func getPlayers_EmptyStore_ShouldReturnEmpty() async throws {
        let result = try await sut.getPlayers()
        #expect(result.isEmpty)
    }

    @Test
    func getPlayers_ShouldReturnActivePlayersSortedByName() async throws {
        let mercedes = helper.makePlayer("Mercedes")
        helper.makePlayer("Dani")
        helper.makePlayer("Lucía", isArchived: true)
        try helper.save()

        let result = try await sut.getPlayers()

        #expect(result.map(\.name) == ["Dani", "Mercedes"])
        #expect(result.last == Domain.PlayerModel(id: mercedes.id, name: "Mercedes"))
    }

    @Test
    func addPlayer_ShouldPersistPlayer() async throws {
        let created = try await sut.addPlayer(Domain.NewPlayerModel(name: "Lucía"))

        let result = try await sut.getPlayers()

        #expect(created.name == "Lucía")
        #expect(result == [created])
        #expect(try helper.count(PlayerEntity.self) == 1)
    }
}
