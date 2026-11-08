//
//  GetLastGamesUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 18/10/2026.
//

import Foundation

public protocol GetLastGamesUseCaseProtocol: Sendable {
    func callAsFunction() async throws -> [Domain.GetLastGamesModel]
}

public struct GetLastGamesUseCase {
    private let repository: DashboardRepositoryProtocol

    public init(
        repository: DashboardRepositoryProtocol
    ) {
        self.repository = repository
    }
}

extension GetLastGamesUseCase: GetLastGamesUseCaseProtocol {
    public func callAsFunction() async throws -> [Domain.GetLastGamesModel] {
        try await repository.getLastGames()
    }
}

enum GetLastNameUseCaseError: Error {
    case test
}
