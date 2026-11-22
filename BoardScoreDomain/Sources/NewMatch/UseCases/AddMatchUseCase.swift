//
//  AddMatchUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 17/11/2026.
//

public protocol AddMatchUseCaseProtocol: Sendable {
    func callAsFunction(_ match: Domain.NewMatchModel) async throws
}

public struct AddMatchUseCase {
    private let repository: MatchesRepositoryProtocol

    public init(repository: MatchesRepositoryProtocol) {
        self.repository = repository
    }
}

extension AddMatchUseCase: AddMatchUseCaseProtocol {
    public func callAsFunction(_ match: Domain.NewMatchModel) async throws {
        try await repository.addMatch(match)
    }
}
