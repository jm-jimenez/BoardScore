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

    public init(
        getLastGamesMapper: GetLastGamesMapperProtocol = GetLastGamesMapper()
    ) {
        self.getLastGamesMapper = getLastGamesMapper
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
}
