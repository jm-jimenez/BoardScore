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
import BoardScorePresentationMocks
@testable import BoardScorePresentation

@MainActor
// swiftlint:disable:next type_body_length
struct NewMatchViewModelTests {

    let sut: NewMatchViewModel
    let getGamesUseCaseMock = GetGamesUseCaseMock()
    let getPlayersUseCaseMock = GetPlayersUseCaseMock()
    let addPlayerUseCaseMock = AddPlayerUseCaseMock()
    let addMatchUseCaseMock = AddMatchUseCaseMock()
    let router = NewMatchRouterMock()
    private let onFinishSpy: OnFinishSpy

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
        let onFinishSpy = OnFinishSpy()
        self.onFinishSpy = onFinishSpy
        sut = NewMatchViewModel(
            getGamesUseCase: getGamesUseCaseMock,
            getPlayersUseCase: getPlayersUseCaseMock,
            addPlayerUseCase: addPlayerUseCaseMock,
            addMatchUseCase: addMatchUseCaseMock,
            resolveWinnersUseCase: ResolveWinnersUseCase(),
            router: router,
            onFinish: { onFinishSpy() }
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
    func addNewGame_ShouldAskRouterAndSelectCreatedGame() async {
        await load()
        let azul = Domain.GameModel.mock(name: "Azul")

        sut.addNewGame()
        router.receivedOnCreate?(azul)

        #expect(router.showNewGameCount == 1)
        #expect(sut.games == [azul, golf, wingspan])
        #expect(sut.selectedGame == azul)
    }

    @Test
    func addNewGame_WithScores_ShouldAskBeforeSelectingCreatedGame() async {
        await startMatch(players: [mercedes])
        sut.updateScore("12", for: mercedes, scoreable: wingspan.scoreables[0])
        let azul = Domain.GameModel.mock(name: "Azul")

        sut.addNewGame()
        router.receivedOnCreate?(azul)

        #expect(sut.games.contains(azul))
        #expect(sut.selectedGame == wingspan)
        #expect(sut.pendingGame == azul)
    }

    @Test
    func addPlayers_ShouldUpdateParticipantsAndAvailablePlayers() async throws {
        await load()
        sut.addExistingPlayer(mercedes)
        sut.addExistingPlayer(mercedes)
        sut.addNewPlayer(name: "   ")
        sut.addNewPlayer(name: "  Lucía  ")
        try await until { sut.participants.count == 2 }

        let calledCount = await addPlayerUseCaseMock.calledCount
        let receivedPlayer = await addPlayerUseCaseMock.receivedPlayer
        #expect(calledCount == 1)
        #expect(receivedPlayer == Domain.NewPlayerModel(name: "Lucía"))
        #expect(sut.participants.map(\.name) == ["Mercedes", "Lucía"])
        #expect(sut.availablePlayers.map(\.name) == ["Dani", "M@rio"])
        #expect(sut.showsAddPlayerError == false)
    }

    @Test
    func addNewPlayer_WhenUseCaseFails_ShouldShowError() async throws {
        struct TestError: Error {}
        await load()
        await addPlayerUseCaseMock.setExecutionReturn { _ in throw TestError() }

        sut.addNewPlayer(name: "Lucía")
        try await until { sut.showsAddPlayerError }

        #expect(sut.participants.isEmpty)
        #expect(sut.availablePlayers.map(\.name) == ["Mercedes", "Dani", "M@rio"])
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
        #expect(sut.isSaving == false)
    }

    @Test
    func save_WithClearWinner_ShouldPersistMatchAndFinish() async throws {
        await startMatch(players: [mercedes, dani])
        let birds = wingspan.scoreables[0]
        let eggs = wingspan.scoreables[1]
        let date = Date(timeIntervalSince1970: 1_000)
        sut.updateScore("20", for: mercedes, scoreable: birds)
        sut.updateScore("35", for: dani, scoreable: birds)
        sut.date = date
        sut.durationMinutes = 45

        sut.save()

        #expect(sut.isSaving)
        #expect(sut.canSave == false)
        try await until { router.finishCount == 1 }
        let match = await addMatchUseCaseMock.receivedMatch
        #expect(onFinishSpy.count == 1)
        #expect(sut.isSaving == false)
        #expect(match?.game == wingspan)
        #expect(match?.playedAt == date)
        #expect(match?.durationMinutes == 45)
        #expect(match?.isWinnerManuallySelected == false)
        #expect(match?.participants.map(\.player) == [mercedes, dani])
        #expect(match?.participants.map(\.turnOrder) == [0, 1])
        #expect(match?.participants.map(\.isWinner) == [false, true])
        #expect(match?.participants.first?.scores == [birds: 20, eggs: 0])
    }

    @Test
    func save_WhenUseCaseFails_ShouldShowErrorAndStayOpen() async throws {
        struct TestError: Error {}
        await addMatchUseCaseMock.setExecutionReturn { _ in throw TestError() }
        await startMatch(players: [mercedes, dani])
        sut.updateScore("20", for: mercedes, scoreable: wingspan.scoreables[0])

        sut.save()

        try await until { sut.showsSaveError }
        #expect(sut.isSaving == false)
        #expect(sut.canSave)
        #expect(router.finishCount == 0)
        #expect(onFinishSpy.count == 0)
    }

    @Test
    func save_WithTie_ShouldAskForWinnerThenPersistMatch() async throws {
        await startMatch(players: [mercedes, dani, mario])
        let birds = wingspan.scoreables[0]
        sut.updateScore("10", for: mercedes, scoreable: birds)
        sut.updateScore("10", for: dani, scoreable: birds)
        sut.updateScore("3", for: mario, scoreable: birds)

        sut.save()
        #expect(sut.isSaving == false)
        #expect(sut.tiedPlayers.map(\.name) == ["Mercedes", "Dani"])

        sut.cancelTie()
        #expect(sut.tiedPlayers.isEmpty)

        sut.save()
        sut.selectTieWinner(dani)

        #expect(sut.tiedPlayers.isEmpty)
        try await until { onFinishSpy.count == 1 }
        let match = await addMatchUseCaseMock.receivedMatch
        #expect(match?.isWinnerManuallySelected == true)
        #expect(match?.participants.map(\.isWinner) == [false, true, false])
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
        #expect(sut.isSaving == false)
    }
}

private extension NewMatchViewModelTests {
    @MainActor
    final class OnFinishSpy {
        private(set) var count = 0

        func callAsFunction() {
            count += 1
        }
    }

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
