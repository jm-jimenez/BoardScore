//
//  GetGamesUseCaseMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import BoardScoreDomain

public actor GetGamesUseCaseMock: GetGamesUseCaseProtocol {

    public init() {}

    public var calledCount = 0
    public var executionReturn: (@Sendable () async throws -> [Domain.GameModel])?

    public func callAsFunction() async throws -> [Domain.GameModel] {
        calledCount += 1
        guard let executionReturn else {
            return []
        }

        return try await executionReturn()
    }

    public func setExecutionReturn(_ newValue: @Sendable @escaping () async throws -> [Domain.GameModel]) {
        executionReturn = newValue
    }
}
