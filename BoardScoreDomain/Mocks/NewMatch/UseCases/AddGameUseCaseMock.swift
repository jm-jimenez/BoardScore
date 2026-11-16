//
//  AddGameUseCaseMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import BoardScoreDomain

public actor AddGameUseCaseMock: AddGameUseCaseProtocol {

    public init() {}

    public var calledCount = 0
    public var receivedGame: Domain.NewGameModel?
    public var executionReturn: (@Sendable (Domain.NewGameModel) async throws -> Domain.GameModel)?

    public func callAsFunction(_ game: Domain.NewGameModel) async throws -> Domain.GameModel {
        calledCount += 1
        receivedGame = game
        guard let executionReturn else {
            return Domain.GameModel(
                id: UUID(),
                name: game.name,
                winCondition: game.winCondition,
                scoreables: game.scoreableNames.map { Domain.ScoreableModel(id: UUID(), name: $0) }
            )
        }

        return try await executionReturn(game)
    }

    public func setExecutionReturn(
        _ newValue: @Sendable @escaping (Domain.NewGameModel) async throws -> Domain.GameModel
    ) {
        executionReturn = newValue
    }
}
