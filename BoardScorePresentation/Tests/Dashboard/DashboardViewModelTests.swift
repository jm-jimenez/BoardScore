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
    var useCase: GetLastGamesUseCaseMock

    init() {
        self.useCase = GetLastGamesUseCaseMock()
        let dependencies = DashboardFactory.Dependency(external: DashboardExternalDependenciesTest())
        self.sut = DashboardViewModel(
            getLastGamesUseCase: useCase,
            getTopWinnersUseCase: dependencies.resolve(),
            lastGamesMapper: dependencies.resolve(),
            topWinnersMapper: dependencies.resolve()
        )
    }

    @Test
    func onAppear_WhenCalled_StateShouldBeCorrect() async throws {
        await useCase.setExecutionReturn {
            [.mock()]
        }
        sut.onAppear()
        try await until {
            sut.state.isContent
        }
        guard case .content(let contentData) = sut.state else {
            Issue.record("Expected .content state, got \(sut.state)")
            return
        }
        let count = await useCase.calledCount
        let resultCount = contentData.gamesViewData.items.count
        #expect(count == 1)
        #expect(resultCount == 1)
    }

    @Test
    func onAppear_WhenUseCasesThrow_ThenStateShouldBeError() async throws {
        struct TestError: Error {}
        await useCase.setExecutionReturn {
            throw TestError()
        }
        sut.onAppear()
        try await until {
            if case .error = sut.state {
                return true
            } else {
                return false
            }
        }
    }

    @Test
    func onAppear_MultipleCalls_ShouldNotIncrementCount() async throws {
        await useCase.setExecutionReturn {
            try await Task.sleep(nanoseconds: 3_000_000)
            return [.mock()]
        }
        sut.onAppear()
        sut.onAppear()
        sut.onAppear()
        try await until {
            sut.state.isContent
        }
        let calledCount = await useCase.calledCount
        #expect(calledCount == 1)
    }
}

func until(condition: @escaping () -> Bool,
           timeout: Double = 5,
           isolation _: isolated (any Actor?) = #isolation,
           _ file: String = #file,
           _ line: Int = #line,
           _ sourceLocation: SourceLocation = #_sourceLocation
) async throws {
    enum TestError: Error {
        case timedOut
    }

    let date = Date().advanced(by: timeout)
    while !condition() {
        if Date() > date {
            Issue.record(TestError.timedOut, sourceLocation: sourceLocation)
            throw TestError.timedOut
        }
        await Task.yield()
    }
}
