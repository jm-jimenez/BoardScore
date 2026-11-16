//
//  MockPlayersRepositoryTests.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing

@testable import BoardScoreData

struct MockPlayersRepositoryTests {

    @Test
    func getPlayers_ShouldReturnStablePlayers() async throws {
        let sut = MockPlayersRepository()

        let first = try await sut.getPlayers()
        let second = try await sut.getPlayers()

        #expect(first.map(\.name) == ["Mercedes", "Dani", "M@rio", "Lucía"])
        #expect(first == second)
    }
}
