//
//  GetTopWinnersUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 25/10/2026.
//

public protocol GetTopWinnersUseCaseProtocol: Sendable {
    func callAsFunction() async throws -> [Domain.GetTopWinnersModel]
}

public struct GetTopWinnersUseCase {
    private let repository: DashboardRepositoryProtocol

    public init(
        repository: DashboardRepositoryProtocol
    ) {
        self.repository = repository
    }
}

extension GetTopWinnersUseCase: GetTopWinnersUseCaseProtocol {
    public func callAsFunction() async throws -> [Domain.GetTopWinnersModel] {
        try await repository.getTopWinners()
    }
}
