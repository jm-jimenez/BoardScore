//
//  AddMatchUseCaseMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 17/11/2026.
//

import BoardScoreDomain

public actor AddMatchUseCaseMock: AddMatchUseCaseProtocol {

    public init() {}

    public var calledCount = 0
    public var receivedMatch: Domain.NewMatchModel?
    public var executionReturn: (@Sendable (Domain.NewMatchModel) async throws -> Void)?

    public func callAsFunction(_ match: Domain.NewMatchModel) async throws {
        calledCount += 1
        receivedMatch = match
        try await executionReturn?(match)
    }

    public func setExecutionReturn(
        _ newValue: @Sendable @escaping (Domain.NewMatchModel) async throws -> Void
    ) {
        executionReturn = newValue
    }
}
