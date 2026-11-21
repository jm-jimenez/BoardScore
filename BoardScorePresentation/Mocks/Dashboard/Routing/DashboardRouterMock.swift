//
//  DashboardRouterMock.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import BoardScorePresentation

@MainActor
public final class DashboardRouterMock: DashboardRouting {
    public private(set) var showNewMatchCount = 0
    public private(set) var receivedOnFinish: (@MainActor () -> Void)?

    public init() {}

    public func showNewMatch(onFinish: @escaping @MainActor () -> Void) {
        showNewMatchCount += 1
        receivedOnFinish = onFinish
    }
}
