//
//  DashboardRepository.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 08/11/2026.
//

public protocol DashboardRepositoryProtocol: Sendable {
    func getLastGames() async throws -> [Domain.GetLastGamesModel]
    func getTopWinners() async throws -> [Domain.GetTopWinnersModel]
}
