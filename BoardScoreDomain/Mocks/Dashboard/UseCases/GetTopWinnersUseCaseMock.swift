//
//  GetTopWinnersUseCaseMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 09/11/2026.
//

import BoardScoreDomain

public actor GetTopWinnersUseCaseMock: GetTopWinnersUseCaseProtocol {

    public init() {}

    public var calledCount = 0
    public var executionReturn: (@Sendable () async throws -> [Domain.GetTopWinnersModel])?

    public func callAsFunction() async throws -> [Domain.GetTopWinnersModel] {
        calledCount += 1
        guard let executionReturn else {
            return []
        }

        return try await executionReturn()
    }

    public func setExecutionReturn(_ newValue: @Sendable @escaping () async throws -> [Domain.GetTopWinnersModel]) {
        executionReturn = newValue
    }

}
