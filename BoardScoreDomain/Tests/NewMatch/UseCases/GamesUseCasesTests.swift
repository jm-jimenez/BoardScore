//
//  GamesUseCasesTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct GamesUseCasesTests {

    @Test
    func getGames_ShouldReturnRepositoryGames() async throws {
        let games: [Domain.GameModel] = [.mock(name: "Azul"), .mock(name: "Catan")]
        let sut = GetGamesUseCase(repository: GamesRepositoryMock(games: games))

        let result = try await sut()

        #expect(result == games)
    }

    @Test
    func addGame_ShouldReturnCreatedGame() async throws {
        let sut = AddGameUseCase(repository: GamesRepositoryMock())
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

    @Test
    func getPlayers_ShouldReturnRepositoryPlayers() async throws {
        let players: [Domain.PlayerModel] = [.mock(name: "Dani"), .mock(name: "Mercedes")]
        let sut = GetPlayersUseCase(repository: PlayersRepositoryMock(players: players))

        let result = try await sut()

        #expect(result == players)
    }
}
