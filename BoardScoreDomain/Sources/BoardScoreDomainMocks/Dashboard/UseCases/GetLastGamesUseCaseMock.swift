//
//  GetLastGamesUseCaseMocks.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 26/10/2026.
//

import BoardScoreDomain

public actor GetLastGamesUseCaseMock: GetLastGamesUseCaseProtocol {

    public init() {}

    public var calledCount = 0
    public var executionReturn: (@Sendable () throws -> [Domain.GetLastGamesModel])?

    public func callAsFunction() async throws -> [Domain.GetLastGamesModel] {
        calledCount += 1
        guard let executionReturn else {
            return []
        }
        return try executionReturn()
    }

    public func setExecutionReturn(_ newValue: @Sendable @escaping () throws -> [Domain.GetLastGamesModel]) {
        executionReturn = newValue
    }
}
