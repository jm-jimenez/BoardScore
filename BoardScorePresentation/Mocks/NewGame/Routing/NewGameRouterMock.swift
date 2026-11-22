//
//  NewGameRouterMock.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 16/11/2026.
//

import BoardScorePresentation

@MainActor
public final class NewGameRouterMock: NewGameRouting {
    public private(set) var closeCount = 0
    public private(set) var finishCount = 0

    public init() {}

    public func closeNewGame() {
        closeCount += 1
    }

    public func newGameDidFinish() {
        finishCount += 1
    }
}
