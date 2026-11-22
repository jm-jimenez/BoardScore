//
//  GetGameStatsUseCaseMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 21/11/2026.
//

import BoardScoreDomain

public actor GetGameStatsUseCaseMock: GetGameStatsUseCaseProtocol {

    public init() {}

    public var calledCount = 0
    public var receivedGame: Domain.GameModel?
    public var executionReturn: (@Sendable (Domain.GameModel) async throws -> Domain.GameStatsModel)?

    public func callAsFunction(game: Domain.GameModel) async throws -> Domain.GameStatsModel {
        calledCount += 1
        receivedGame = game
        guard let executionReturn else {
            return .mock()
        }

        return try await executionReturn(game)
    }

    public func setExecutionReturn(
        _ newValue: @Sendable @escaping (Domain.GameModel) async throws -> Domain.GameStatsModel
    ) {
        executionReturn = newValue
    }
}
