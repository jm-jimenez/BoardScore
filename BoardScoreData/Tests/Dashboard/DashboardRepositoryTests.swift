//
//  DashboardRepositoryTests.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 18/10/2026.
//

import Testing
@testable import BoardScoreData

struct DashboardRepositoryTests {

    let sut: DefaultDashboardRepository

    init() {
        sut = DefaultDashboardRepository()
    }

    @Test
    func getLastGames_ShouldCountTwo() async throws {
        let result = try await sut.getLastGames()
        #expect(result.count == 2)
    }

    @Test
    func getTopWinners_ShouldCountTwo() async throws {
        let result = try await sut.getTopWinners()
        #expect(result.count == 2)
    }
}
