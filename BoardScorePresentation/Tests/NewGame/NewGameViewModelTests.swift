//
//  NewGameViewModelTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 16/11/2026.
//

import Foundation
import Testing
import BoardScoreDomain
import BoardScoreDomainMocks
import BoardScorePresentationMocks
@testable import BoardScorePresentation

@MainActor
struct NewGameViewModelTests {

    let sut: NewGameViewModel
    let getGamesUseCaseMock = GetGamesUseCaseMock()
    let addGameUseCaseMock = AddGameUseCaseMock()
    let router = NewGameRouterMock()
    private let onCreateSpy: OnCreateSpy

    init() {
        let onCreateSpy = OnCreateSpy()
        self.onCreateSpy = onCreateSpy
        sut = NewGameViewModel(
            getGamesUseCase: getGamesUseCaseMock,
            addGameUseCase: addGameUseCaseMock,
            router: router,
            onCreate: { onCreateSpy.receive($0) }
        )
    }

    @Test
    func onAppear_ShouldLoadExistingNames() async {
        await loadGames()
        #expect(sut.existingNames == ["Wingspan", "Golf"])
    }

    @Test
    func onAppear_WhenUseCaseFails_ShouldHaveNoNames() async {
        struct TestError: Error {}
        await getGamesUseCaseMock.setExecutionReturn { throw TestError() }

        await sut.onAppear()

        #expect(sut.existingNames.isEmpty)
    }

    @Test
    func initialState_ShouldStartWithOneEmptyScoreable() {
        #expect(sut.name.isEmpty)
        #expect(sut.winCondition == .highestScore)
        #expect(sut.scoreables.map(\.name) == [""])
        #expect(sut.hasScoreables)
        #expect(sut.hasEmptyScoreables)
        #expect(sut.canSave == false)
    }

    @Test
    func isDuplicateName_ShouldIgnoreCaseAndSurroundingSpaces() async {
        await loadGames()

        sut.name = "  wingspan "
        #expect(sut.isDuplicateName)

        sut.name = "Azul"
        #expect(sut.isDuplicateName == false)

        sut.name = "   "
        #expect(sut.isDuplicateName == false)
    }

    @Test
    func canSave_ShouldRequireUniqueNameAndNoEmptyScoreables() async {
        await loadGames()
        sut.renameScoreable(sut.scoreables[0], to: "   ")
        sut.name = "Azul"
        #expect(sut.hasEmptyScoreables)
        #expect(sut.canSave == false)

        sut.renameScoreable(sut.scoreables[0], to: "Tiles")
        #expect(sut.hasEmptyScoreables == false)
        #expect(sut.canSave)

        sut.addScoreable()
        #expect(sut.hasEmptyScoreables)
        #expect(sut.canSave == false)

        sut.removeScoreables(at: IndexSet(integer: 1))
        #expect(sut.canSave)

        sut.removeScoreables(at: IndexSet(integer: 0))
        #expect(sut.hasScoreables == false)
        #expect(sut.hasEmptyScoreables == false)
        #expect(sut.canSave == false)

        sut.addScoreable()
        sut.renameScoreable(sut.scoreables[0], to: "Tiles")

        sut.name = "Golf"
        #expect(sut.canSave == false)

        sut.name = " "
        #expect(sut.canSave == false)
    }

    @Test
    func scoreables_ShouldAddRenameMoveAndRemove() {
        sut.renameScoreable(sut.scoreables[0], to: "Birds")
        sut.addScoreable()
        sut.renameScoreable(sut.scoreables[1], to: "Eggs")
        sut.addScoreable()
        sut.renameScoreable(sut.scoreables[2], to: "Food")
        #expect(sut.scoreables.map(\.name) == ["Birds", "Eggs", "Food"])

        sut.moveScoreables(from: IndexSet(integer: 2), to: 0)
        #expect(sut.scoreables.map(\.name) == ["Food", "Birds", "Eggs"])

        sut.removeScoreables(at: IndexSet(integer: 1))
        #expect(sut.scoreables.map(\.name) == ["Food", "Eggs"])

        sut.renameScoreable(Domain.ScoreableModel(name: "Unknown"), to: "Ignored")
        #expect(sut.scoreables.map(\.name) == ["Food", "Eggs"])
    }

    @Test
    func save_ShouldCreateTrimmedGameOnceAndNotifyRouter() async throws {
        await loadGames()
        sut.name = "  Azul "
        sut.winCondition = .lowestScore
        sut.renameScoreable(sut.scoreables[0], to: " Tiles ")
        sut.addScoreable()
        sut.renameScoreable(sut.scoreables[1], to: "Bonus ")
        sut.addScoreable()
        sut.renameScoreable(sut.scoreables[2], to: "Penalty")

        sut.save()
        #expect(sut.canSave == false)
        sut.save()
        try await until { router.finishCount == 1 }

        let calledCount = await addGameUseCaseMock.calledCount
        let receivedGame = await addGameUseCaseMock.receivedGame
        #expect(calledCount == 1)
        #expect(receivedGame == Domain.NewGameModel(
            name: "Azul",
            winCondition: .lowestScore,
            scoreableNames: ["Tiles", "Bonus", "Penalty"]
        ))
        #expect(router.finishCount == 1)
        #expect(onCreateSpy.calledCount == 1)
        #expect(onCreateSpy.receivedGame?.name == "Azul")
        #expect(onCreateSpy.receivedGame?.scoreables.map(\.name) == ["Tiles", "Bonus", "Penalty"])
        #expect(sut.showsSaveError == false)
        #expect(sut.canSave)
    }

    @Test
    func save_WhenCannotSave_ShouldDoNothing() async {
        sut.save()

        let calledCount = await addGameUseCaseMock.calledCount
        #expect(calledCount == 0)
        #expect(router.finishCount == 0)
        #expect(onCreateSpy.calledCount == 0)
    }

    @Test
    func save_WhenUseCaseFails_ShouldShowError() async throws {
        struct TestError: Error {}
        await addGameUseCaseMock.setExecutionReturn { _ in throw TestError() }
        sut.name = "Azul"
        sut.renameScoreable(sut.scoreables[0], to: "Tiles")

        sut.save()
        try await until { sut.showsSaveError }

        #expect(sut.canSave)
        #expect(router.finishCount == 0)
        #expect(onCreateSpy.calledCount == 0)
    }

    @Test
    func cancel_ShouldAskRouterToClose() {
        sut.cancel()
        #expect(router.closeCount == 1)
        #expect(onCreateSpy.calledCount == 0)
    }
}

private extension NewGameViewModelTests {
    @MainActor
    final class OnCreateSpy {
        private(set) var calledCount = 0
        private(set) var receivedGame: Domain.GameModel?

        func receive(_ game: Domain.GameModel) {
            calledCount += 1
            receivedGame = game
        }
    }

    func loadGames() async {
        let games = [Domain.GameModel.mock(name: "Wingspan"), Domain.GameModel.mock(name: "Golf")]
        await getGamesUseCaseMock.setExecutionReturn { games }
        await sut.onAppear()
    }
}
