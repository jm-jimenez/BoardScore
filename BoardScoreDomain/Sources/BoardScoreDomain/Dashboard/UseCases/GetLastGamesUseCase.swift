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
    private let mapper: GetLastGamesMapperProtocol

    public init() {
        repository = DefaultDashboardRepository()
        mapper = GetLastGamesMapper()
    }

    public init(
        repository: DashboardRepositoryProtocol,
        mapper: GetLastGamesMapperProtocol
    ) {
        self.repository = repository
        self.mapper = mapper
    }
}

extension GetLastGamesUseCase: GetLastGamesUseCaseProtocol {
    public func callAsFunction() async throws -> [Domain.GetLastGamesModel] {
        let lastGames = try await repository.getLastGames()
        return mapper.map(lastGames)
//        [
//            .init(name: "Dominion",
//                  winner: "Dani",
//                  date: Date()
//                 ),
//            .init(name: "Wingspan",
//                  winner: "Mercedes",
//                  date: Date())
//        ]
    }
}

enum GetLastNameUseCaseError: Error {
    case test
}
