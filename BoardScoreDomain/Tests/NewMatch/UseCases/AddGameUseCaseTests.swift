//
//  AddGameUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct AddGameUseCaseTests {
    let sut: AddGameUseCase
    let repository: GamesRepositoryMock

    init() {
        repository = GamesRepositoryMock()
        sut = AddGameUseCase(repository: repository)
    }

    @Test
    func whenCalled_ShouldReturnCreatedGame() async throws {
        let newGame = Domain.NewGameModel.mock(
            name: "Dominion",
            winCondition: .lowestScore,
            scoreableNames: ["VP", "Curses"]
        )

        let result = try await sut(newGame)

        #expect(result.name == "Dominion")
        #expect(result.winCondition == .lowestScore)
        #expect(result.scoreables.map(\.name) == ["VP", "Curses"])
    }
}
