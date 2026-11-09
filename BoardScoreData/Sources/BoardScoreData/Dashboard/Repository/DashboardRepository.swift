//
//  DashboardRepository.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 18/10/2026.
//

import Foundation
import BoardScoreDomain

public struct DefaultDashboardRepository {
    private let getLastGamesMapper: GetLastGamesMapperProtocol
    private let getTopWinnersMapper: GetTopWinnersMapperProtocol

    public init(
        getLastGamesMapper: GetLastGamesMapperProtocol = GetLastGamesMapper(),
        getTopWinnersMapper: GetTopWinnersMapperProtocol = GetTopWinnersMapper()
    ) {
        self.getLastGamesMapper = getLastGamesMapper
        self.getTopWinnersMapper = getTopWinnersMapper
    }
}

extension DefaultDashboardRepository: DashboardRepositoryProtocol {
    public func getLastGames() async throws -> [Domain.GetLastGamesModel] {
        getLastGamesMapper.map(
            [
                .init(name: "Dominion",
                      winner: "Dani",
                      date: Date()
                     ),
                .init(name: "Wingspan",
                      winner: "Mercedes",
                      date: Date())
            ]
        )
    }

    public func getTopWinners() async throws -> [Domain.GetTopWinnersModel] {
        getTopWinnersMapper.map(
            [
                .init(name: "Mercedes",
                      lastGameWin: "Wingspan",
                      wins: 13,
                      losses: 6),
                .init(name: "M@rio",
                      lastGameWin: "Alquimistas",
                      wins: 8,
                      losses: 3)
            ]
        )
    }
}
