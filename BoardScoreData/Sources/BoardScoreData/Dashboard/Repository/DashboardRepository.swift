//
//  DashboardRepository.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 18/10/2026.
//

import Foundation

public protocol DashboardRepositoryProtocol: Sendable {
    func getLastGames() async throws -> [Data.GetLastGamesModel]
}

public struct DefaultDashboardRepository {
    public init() { }
}

extension DefaultDashboardRepository: DashboardRepositoryProtocol {
    public func getLastGames() async throws -> [Data.GetLastGamesModel] {
        [
            .init(name: "Dominion",
                  winner: "Dani",
                  date: Date()
                 ),
            .init(name: "Wingspan",
                  winner: "Mercedes",
                  date: Date())
        ]
    }
}
