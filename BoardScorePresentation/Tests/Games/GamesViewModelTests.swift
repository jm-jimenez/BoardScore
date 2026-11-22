//
//  GamesViewModelTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import Foundation
import Testing
import BoardScoreDomain
import BoardScoreDomainMocks
@testable import BoardScorePresentation

@MainActor
struct GamesViewModelTests {
    let sut: GamesViewModel
    let getGamesUseCaseMock = GetGamesUseCaseMock()
    let getGameStatsUseCaseMock = GetGameStatsUseCaseMock()
    let azul = Domain.GameModel.mock(name: "Azul")
    let catan = Domain.GameModel.mock(name: "Catan")

    init() {
        sut = GamesViewModel(
            getGamesUseCase: getGamesUseCaseMock,
            getGameStatsUseCase: getGameStatsUseCaseMock,
            statsMapper: GameStatsMapper(locale: Locale(identifier: "en_US"))
        )
    }

    @Test
    func initialState_ShouldBeIdle() {
        #expect(sut.state == .idle)
        #expect(sut.games.isEmpty)
        #expect(sut.selectedGame == nil)
    }

    @Test
    func onAppear_ShouldSelectFirstGameAndShowItsStats() async {
        await givenGames([azul, catan])

        await sut.onAppear()

        #expect(sut.games == [azul, catan])
        #expect(sut.selectedGame == azul)
        #expect(sut.state == .content(GameStatsMapper(locale: Locale(identifier: "en_US")).map(.mock())))
        #expect(await getGameStatsUseCaseMock.receivedGame == azul)
    }

    @Test
    func onAppear_WhenNoGames_StateShouldBeNoGames() async {
        await givenGames([])

        await sut.onAppear()

        #expect(sut.state == .noGames)
        #expect(sut.selectedGame == nil)
        #expect(await getGameStatsUseCaseMock.calledCount == 0)
    }

    @Test
    func onAppear_WhenGamesFail_StateShouldBeError() async {
        await getGamesUseCaseMock.setExecutionReturn { throw TestError() }

        await sut.onAppear()

        #expect(sut.state == .error)
    }

    @Test
    func onAppear_WhenStatsFail_StateShouldBeError() async {
        await givenGames([azul])
        await getGameStatsUseCaseMock.setExecutionReturn { _ in throw TestError() }

        await sut.onAppear()

        #expect(sut.state == .error)
    }

    @Test
    func onAppear_WhenGameNotPlayed_StateShouldBeNotPlayed() async {
        await givenGames([azul])
        await getGameStatsUseCaseMock.setExecutionReturn { _ in .mock(timesPlayed: 0) }

        await sut.onAppear()

        #expect(sut.state == .notPlayed)
        #expect(sut.state.isContent == false)
    }

    @Test
    func selectGame_ShouldLoadStatsForTheSelectedGame() async throws {
        await givenGamesWithStats([azul, catan])
        await sut.onAppear()

        sut.selectGame(catan)

        #expect(sut.selectedGame == catan)
        #expect(sut.state == .loading)
        try await until { timesPlayed == "2" }
        #expect(await getGameStatsUseCaseMock.receivedGame == catan)
    }

    @Test
    func selectGame_WhenAlreadySelected_ShouldDoNothing() async {
        await givenGamesWithStats([azul, catan])
        await sut.onAppear()

        sut.selectGame(azul)

        #expect(sut.state.isContent)
        #expect(await getGameStatsUseCaseMock.calledCount == 1)
    }

    @Test
    func selectGame_ShouldIgnoreThePreviousSelectionResult() async throws {
        let slowGame = Domain.GameModel.mock(name: "Slow")
        await givenGames([azul, slowGame, catan])
        await getGameStatsUseCaseMock.setExecutionReturn { game in
            if game.name == "Slow" {
                try await Task.sleep(for: .milliseconds(200))
                return .mock(timesPlayed: 99)
            }
            return .mock(timesPlayed: game.name == "Catan" ? 2 : 1)
        }
        await sut.onAppear()

        sut.selectGame(slowGame)
        sut.selectGame(catan)

        try await until { timesPlayed == "2" }
        try await Task.sleep(for: .milliseconds(300))
        #expect(timesPlayed == "2")
        #expect(sut.selectedGame == catan)
    }

    @Test
    func onAppear_WhenCalledAgain_ShouldKeepTheSelectedGame() async throws {
        await givenGamesWithStats([azul, catan])
        await sut.onAppear()
        sut.selectGame(catan)
        try await until { timesPlayed == "2" }

        await sut.onAppear()

        #expect(sut.selectedGame == catan)
        #expect(timesPlayed == "2")
    }

    @Test
    func placeholder_ShouldHaveChartAndRows() {
        let placeholder = GameStatsViewData.placeholder
        #expect(placeholder.winners.slices.count == 3)
        #expect(placeholder.stats.rows.count == 4)
    }
}

private extension GamesViewModelTests {
    struct TestError: Error {}

    var timesPlayed: String? {
        guard case .content(let viewData) = sut.state else { return nil }

        return viewData.stats.rows.first?.value
    }

    func givenGames(_ games: [Domain.GameModel]) async {
        await getGamesUseCaseMock.setExecutionReturn { games }
    }

    func givenGamesWithStats(_ games: [Domain.GameModel]) async {
        await givenGames(games)
        await getGameStatsUseCaseMock.setExecutionReturn { game in
            .mock(timesPlayed: (games.firstIndex(of: game) ?? 0) + 1)
        }
    }
}
