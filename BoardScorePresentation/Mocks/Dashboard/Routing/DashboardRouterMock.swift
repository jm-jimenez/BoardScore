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

    public init() {}

    public func showNewMatch() {
        showNewMatchCount += 1
    }
}
