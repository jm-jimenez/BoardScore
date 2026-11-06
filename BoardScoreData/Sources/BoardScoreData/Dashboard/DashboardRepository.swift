//
//  DashboardRepository.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 18/10/2026.
//

public protocol DashboardRepositoryProtocol: Sendable {
    func getLastGames() async throws -> [Data.GetLastGamesModel]
}

public struct DefaultDashboardRepository {
    public init() { }
}

extension DefaultDashboardRepository: DashboardRepositoryProtocol {
    public func getLastGames() async throws -> [Data.GetLastGamesModel] {
        return []
    }
}


public extension Data {
    struct GetLastGamesModel {

    }
}
