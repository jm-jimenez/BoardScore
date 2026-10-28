//
//  GetLastGamesUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 18/10/2026.
//

import Foundation
import BoardScoreData

public protocol GetLastGamesUseCaseProtocol: Sendable {
    func callAsFunction() async throws -> [Domain.GetLastGamesModel]
}

public struct GetLastGamesUseCase {
    private let repository: DashboardRepositoryProtocol

    public init(
        repository: DashboardRepositoryProtocol = DefaultDashboardRepository()
    ) {
        self.repository = repository
    }
}

extension GetLastGamesUseCase: GetLastGamesUseCaseProtocol {
    public func callAsFunction() async throws -> [Domain.GetLastGamesModel] {
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

public extension Domain {
    struct GetLastGamesModel: Sendable {
        public let name: String
        public let winner: String
        public let date: Date

        public init(name: String, winner: String, date: Date) {
            self.name = name
            self.winner = winner
            self.date = date
        }
    }
}

enum GetLastNameUseCaseError: Error {
    case test
}
