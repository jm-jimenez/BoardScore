//
//  GetGamesUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct GetGamesUseCaseTests {
    let sut: GetGamesUseCase
    let repository: GamesRepositoryMock
    let games: [Domain.GameModel]

    init() {
        games = [.mock(name: "Azul"), .mock(name: "Catan")]
        repository = GamesRepositoryMock(games: games)
        sut = GetGamesUseCase(repository: repository)
    }

    @Test
    func whenCalled_ShouldReturnRepositoryGames() async throws {
        let result = try await sut()

        #expect(result == games)
    }
}
