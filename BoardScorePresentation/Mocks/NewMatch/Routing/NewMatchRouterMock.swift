//
//  NewMatchRouterMock.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import BoardScoreDomain
import BoardScorePresentation

@MainActor
public final class NewMatchRouterMock: NewMatchRouting {
    public private(set) var closeCount = 0
    public private(set) var finishCount = 0
    public private(set) var showNewGameCount = 0
    public private(set) var receivedOnCreate: (@MainActor (Domain.GameModel) -> Void)?

    public init() {}

    public func closeNewMatch() {
        closeCount += 1
    }

    public func newMatchDidFinish() {
        finishCount += 1
    }

    public func showNewGame(onCreate: @escaping @MainActor (Domain.GameModel) -> Void) {
        showNewGameCount += 1
        receivedOnCreate = onCreate
    }
}
