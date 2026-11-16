//
//  RouterMocks.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

@testable import BoardScorePresentation

@MainActor
final class DashboardRouterMock: DashboardRouting {
    private(set) var showNewMatchCount = 0

    func showNewMatch() {
        showNewMatchCount += 1
    }
}

@MainActor
final class NewMatchRouterMock: NewMatchRouting {
    private(set) var closeCount = 0
    private(set) var finishCount = 0

    func closeNewMatch() {
        closeCount += 1
    }

    func newMatchDidFinish() {
        finishCount += 1
    }
}
