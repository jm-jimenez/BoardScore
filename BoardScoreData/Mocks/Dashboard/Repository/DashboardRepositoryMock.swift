//
//  DashboardRepositoryMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 23/10/2026.
//

import BoardScoreData

public struct DashboardRepositoryMock: DashboardRepositoryProtocol {
    public init() {}
    
    public func getLastGames() async throws -> [Data.GetLastGamesModel] {
        return []
    }
}
