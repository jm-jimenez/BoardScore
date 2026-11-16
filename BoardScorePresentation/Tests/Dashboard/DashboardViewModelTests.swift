//
//  DashboardViewModelTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import Foundation
import Testing
import BoardScoreDomainMocks
@testable import BoardScorePresentation

@MainActor
struct DashboardViewModelTests {

    let sut: DashboardViewModel
    let router = DashboardRouterMock()
    let getLastGamesUseCaseMock: GetLastGamesUseCaseMock
    let getTopWinnersUseCaseMock: GetTopWinnersUseCaseMock

    init() {
        self.getLastGamesUseCaseMock = GetLastGamesUseCaseMock()
        self.getTopWinnersUseCaseMock = GetTopWinnersUseCaseMock()
        let dependencies = DashboardFactory.Dependency(external: DashboardExternalDependenciesTest())
        self.sut = DashboardViewModel(
            getLastGamesUseCase: getLastGamesUseCaseMock,
            getTopWinnersUseCase: getTopWinnersUseCaseMock,
            lastGamesMapper: dependencies.resolve(),
            topWinnersMapper: dependencies.resolve(),
            router: router
        )
    }

    @Test
    func onAppear_WhenCalled_StateShouldBeCorrect() async {
        await getLastGamesUseCaseMock.setExecutionReturn {
            [.mock()]
        }
        await getTopWinnersUseCaseMock.setExecutionReturn {
            [.mock()]
        }
        await sut.onAppear()
        #expect(sut.state.isContent)
        guard case .content(let contentData) = sut.state else {
            Issue.record("Expected .content state, got \(sut.state)")
            return
        }

        let lastGamesCount = await getLastGamesUseCaseMock.calledCount
        let lastGamesResultCount = contentData.gamesViewData.items.count
        let topWinnersCount = await getTopWinnersUseCaseMock.calledCount
        let topWinnersResultCount = contentData.winnersViewData.items.count
        #expect(lastGamesCount == 1)
        #expect(lastGamesResultCount == 1)
        #expect(topWinnersCount == 1)
        #expect(topWinnersResultCount == 1)
    }

    @Test
    func onAppear_WhenUseCasesThrow_ThenStateShouldBeError() async {
        struct TestError: Error {}
        await getTopWinnersUseCaseMock.setExecutionReturn {
            throw TestError()
        }
        await sut.onAppear()
        #expect(sut.state == .error)
    }

    @Test
    func onAppear_WhenNoGames_StateShouldBeEmpty() async {
        await getLastGamesUseCaseMock.setExecutionReturn {
            []
        }
        await getTopWinnersUseCaseMock.setExecutionReturn {
            []
        }
        await sut.onAppear()
        #expect(sut.state == .empty)
        #expect(sut.state.isContent == false)
    }

    @Test
    func onAddGameTapped_ShouldPresentNewMatch() {
        sut.onAddGameTapped()
        #expect(router.showNewMatchCount == 1)
        #expect(sut.state == .idle)
    }

    @Test
    func placeholder_ShouldHaveThreeItemsPerSection() {
        let placeholder = DashboardViewModelState.ContentData.placeholder
        #expect(placeholder.gamesViewData.items.count == 3)
        #expect(placeholder.winnersViewData.items.count == 3)
    }
}
