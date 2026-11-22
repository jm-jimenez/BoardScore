//
//  AddPlayerUseCaseMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 17/11/2026.
//

import Foundation
import BoardScoreDomain

public actor AddPlayerUseCaseMock: AddPlayerUseCaseProtocol {

    public init() {}

    public var calledCount = 0
    public var receivedPlayer: Domain.NewPlayerModel?
    public var executionReturn: (@Sendable (Domain.NewPlayerModel) async throws -> Domain.PlayerModel)?

    public func callAsFunction(_ player: Domain.NewPlayerModel) async throws -> Domain.PlayerModel {
        calledCount += 1
        receivedPlayer = player
        guard let executionReturn else {
            return Domain.PlayerModel(name: player.name)
        }

        return try await executionReturn(player)
    }

    public func setExecutionReturn(
        _ newValue: @Sendable @escaping (Domain.NewPlayerModel) async throws -> Domain.PlayerModel
    ) {
        executionReturn = newValue
    }
}
