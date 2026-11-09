//
//  DashboardRepositoryMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 23/10/2026.
//

import BoardScoreDomain

public struct DashboardRepositoryMock: DashboardRepositoryProtocol {
    public init() {}

    public func getLastGames() async throws -> [Domain.GetLastGamesModel] {
        return []
    }

    public func getTopWinners() async throws -> [Domain.GetTopWinnersModel] {
        return []
    }
}
