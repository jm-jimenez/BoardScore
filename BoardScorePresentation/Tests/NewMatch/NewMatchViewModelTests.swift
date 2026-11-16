//
//  NewMatchViewModelTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import Testing
import BoardScoreDomain
import BoardScoreDomainMocks
@testable import BoardScorePresentation

@MainActor
struct NewMatchViewModelTests {

    let sut: NewMatchViewModel
    let getGamesUseCaseMock = GetGamesUseCaseMock()
    let addGameUseCaseMock = AddGameUseCaseMock()
    let getPlayersUseCaseMock = GetPlayersUseCaseMock()
    let router = NewMatchRouterMock()

    let wingspan = Domain.GameModel.mock(
        name: "Wingspan",
        scoreables: [
            .mock(name: "Birds"),
            .mock(name: "Eggs")
        ]
    )
    let golf = Domain.GameModel.mock(
        name: "Golf",
        winCondition: .lowestScore,
        scoreables: [.mock(name: "Strokes")]
    )
    let mercedes = Domain.PlayerModel.mock(name: "Mercedes")
    let dani = Domain.PlayerModel.mock(name: "Dani")
    let mario = Domain.PlayerModel.mock(name: "M@rio")

    init() {
        sut = NewMatchViewModel(
            getGamesUseCase: getGamesUseCaseMock,
            addGameUseCase: addGameUseCaseMock,
            getPlayersUseCase: getPlayersUseCaseMock,
            resolveWinnersUseCase: ResolveWinnersUseCase(),
            router: router
        )
    }

    @Test
    func onAppear_ShouldLoadGamesAndPlayers() async {
        await load()

        #expect(sut.games == [golf, wingspan])
        #expect(sut.availablePlayers.map(\.name) == ["Mercedes", "Dani", "M@rio"])
        #expect(sut.selectedGame == nil)
        #expect(sut.canSave == false)
    }

    @Test
    func onAppear_WhenUseCasesFail_ShouldBeEmpty() async {
        struct TestError: Error {}
        await getGamesUseCaseMock.setExecutionReturn { throw TestError() }
        await getPlayersUseCaseMock.setExecutionReturn { throw TestError() }

        await sut.onAppear()

        #expect(sut.games.isEmpty)
        #expect(sut.availablePlayers.isEmpty)
    }

    @Test
    func selectGame_WithoutScores_ShouldApplyDirectly() async {
        await load()

        sut.selectGame(wingspan)

        #expect(sut.selectedGame == wingspan)
        #expect(sut.pendingGame == nil)
    }

    @Test
    func selectGame_WithScores_ShouldAskForConfirmation() async {
        await startMatch(players: [mercedes])
        let birds = wingspan.scoreables[0]
        sut.updateScore("12", for: mercedes, scoreable: birds)

        sut.selectGame(golf)
        #expect(sut.pendingGame == golf)
        #expect(sut.selectedGame == wingspan)

        sut.cancelGameChange()
        #expect(sut.pendingGame == nil)
        #expect(sut.score(for: mercedes, scoreable: birds) == "12")

        sut.selectGame(golf)
        sut.confirmGameChange(golf)
        #expect(sut.selectedGame == golf)
        #expect(sut.pendingGame == nil)
        #expect(sut.hasScores == false)
        #expect(sut.participants.map(\.name) == ["Mercedes"])
    }

    @Test
    func addMockGame_ShouldPersistSortAndSelectIt() async {
        await load()

        await sut.addMockGame()

        let receivedGame = await addGameUseCaseMock.receivedGame
        #expect(receivedGame?.name.hasSuffix("3") == true)
        #expect(sut.games.count == 3)
        #expect(sut.selectedGame?.name == receivedGame?.name)
        let names = sut.games.map(\.name)
        #expect(names == names.sorted { $0.localizedStandardCompare($1) == .orderedAscending })
    }

    @Test
    func addMockGame_WhenUseCaseFails_ShouldKeepGames() async {
        struct TestError: Error {}
        await load()
        await addGameUseCaseMock.setExecutionReturn { _ in throw TestError() }

        await sut.addMockGame()

        #expect(sut.games == [golf, wingspan])
        #expect(sut.selectedGame == nil)
    }

    @Test
    func addPlayers_ShouldUpdateParticipantsAndAvailablePlayers() async {
        await load()
        sut.addExistingPlayer(mercedes)
        sut.addExistingPlayer(mercedes)
        sut.addNewPlayer(name: "  Lucía  ")
        sut.addNewPlayer(name: "   ")

        #expect(sut.participants.map(\.name) == ["Mercedes", "Lucía"])
        #expect(sut.availablePlayers.map(\.name) == ["Dani", "M@rio"])
    }

    @Test
    func movePlayer_ShouldReorderAndRespectBounds() async {
        await startMatch(players: [mercedes, dani, mario])

        #expect(sut.canMove(mercedes, direction: .left) == false)
        #expect(sut.canMove(mercedes, direction: .right))
        #expect(sut.canMove(mario, direction: .right) == false)
        #expect(sut.canMove(Domain.PlayerModel.mock(name: "Nobody"), direction: .left) == false)

        sut.movePlayer(mercedes, direction: .right)
        #expect(sut.participants.map(\.name) == ["Dani", "Mercedes", "M@rio"])

        sut.movePlayer(mario, direction: .left)
        #expect(sut.participants.map(\.name) == ["Dani", "M@rio", "Mercedes"])

        sut.movePlayer(dani, direction: .left)
        #expect(sut.participants.map(\.name) == ["Dani", "M@rio", "Mercedes"])
    }

    @Test
    func removePlayer_ShouldDropParticipantAndScores() async {
        await startMatch(players: [mercedes, dani])
        sut.updateScore("5", for: dani, scoreable: wingspan.scoreables[0])

        sut.removePlayer(dani)

        #expect(sut.participants.map(\.name) == ["Mercedes"])
        #expect(sut.hasScores == false)
        #expect(sut.availablePlayers.map(\.name).contains("Dani"))
    }

    @Test
    func totals_ShouldParseNegativesAndTreatInvalidAsZero() async {
        await startMatch(players: [mercedes, dani])
        let birds = wingspan.scoreables[0]
        let eggs = wingspan.scoreables[1]
        sut.updateScore("30", for: mercedes, scoreable: birds)
        sut.updateScore("-4", for: mercedes, scoreable: eggs)
        sut.updateScore(" 7 ", for: dani, scoreable: birds)
        sut.updateScore("abc", for: dani, scoreable: eggs)

        #expect(sut.total(for: mercedes) == 26)
        #expect(sut.total(for: dani) == 7)
        #expect(sut.totals == [mercedes: 26, dani: 7])
        #expect(sut.leaders == [mercedes])
    }

    @Test
    func leaders_WithoutScoresOrGame_ShouldBeEmpty() async {
        await load()
        #expect(sut.total(for: mercedes) == 0)
        #expect(sut.leaders.isEmpty)

        sut.selectGame(wingspan)
        sut.addExistingPlayer(mercedes)
        #expect(sut.leaders.isEmpty)
    }

    @Test
    func hasDuration_ShouldToggleDefaultDuration() {
        #expect(sut.hasDuration == false)

        sut.hasDuration = true
        #expect(sut.durationMinutes == NewMatchViewModel.defaultDurationMinutes)

        sut.durationMinutes = 95
        sut.hasDuration = true
        #expect(sut.durationMinutes == 95)

        sut.hasDuration = false
        #expect(sut.durationMinutes == nil)
    }

    @Test
    func canSave_ShouldRequireGameAndTwoPlayers() async {
        await load()
        sut.addExistingPlayer(mercedes)
        sut.addExistingPlayer(dani)
        #expect(sut.canSave == false)

        sut.selectGame(wingspan)
        #expect(sut.canSave)

        sut.removePlayer(dani)
        #expect(sut.canSave == false)
        sut.save()
        #expect(sut.result == nil)
    }

    @Test
    func save_WithClearWinner_ShouldBuildResult() async {
        await startMatch(players: [mercedes, dani])
        let birds = wingspan.scoreables[0]
        sut.updateScore("20", for: mercedes, scoreable: birds)
        sut.updateScore("35", for: dani, scoreable: birds)
        sut.durationMinutes = 45

        sut.save()

        let result = sut.result
        #expect(router.finishCount == 1)
        #expect(result?.game == wingspan)
        #expect(result?.durationMinutes == 45)
        #expect(result?.isWinnerManuallySelected == false)
        #expect(result?.participants.map(\.player.name) == ["Mercedes", "Dani"])
        #expect(result?.participants.map(\.turnOrder) == [0, 1])
        #expect(result?.participants.map(\.total) == [20, 35])
        #expect(result?.participants.map(\.isWinner) == [false, true])
        #expect(result?.participants.first?.scores[birds] == 20)
        #expect(result?.participants.first?.scores[wingspan.scoreables[1]] == 0)
    }

    @Test
    func save_WithTie_ShouldAskForWinnerThenBuildResult() async {
        await startMatch(players: [mercedes, dani, mario])
        let birds = wingspan.scoreables[0]
        sut.updateScore("10", for: mercedes, scoreable: birds)
        sut.updateScore("10", for: dani, scoreable: birds)
        sut.updateScore("3", for: mario, scoreable: birds)

        sut.save()
        #expect(sut.result == nil)
        #expect(sut.tiedPlayers.map(\.name) == ["Mercedes", "Dani"])

        sut.cancelTie()
        #expect(sut.tiedPlayers.isEmpty)

        sut.save()
        sut.selectTieWinner(dani)

        #expect(sut.tiedPlayers.isEmpty)
        #expect(sut.result?.isWinnerManuallySelected == true)
        #expect(sut.result?.participants.map(\.isWinner) == [false, true, false])
    }

    @Test
    func cancel_ShouldAskRouterToClose() {
        sut.cancel()
        #expect(router.closeCount == 1)
        #expect(router.finishCount == 0)
    }

    @Test
    func selectTieWinner_WithoutGame_ShouldDoNothing() {
        sut.selectTieWinner(Domain.PlayerModel.mock(name: "Nobody"))
        #expect(sut.result == nil)
    }
}

private extension NewMatchViewModelTests {
    func load() async {
        let games = [golf, wingspan]
        let players = [mercedes, dani, mario]
        await getGamesUseCaseMock.setExecutionReturn { games }
        await getPlayersUseCaseMock.setExecutionReturn { players }
        await sut.onAppear()
    }

    func startMatch(players: [Domain.PlayerModel]) async {
        await load()
        sut.selectGame(wingspan)
        players.forEach { sut.addExistingPlayer($0) }
    }
}
