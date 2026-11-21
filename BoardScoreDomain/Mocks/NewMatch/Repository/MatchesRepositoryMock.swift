//
//  MatchesRepositoryMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 17/11/2026.
//

import BoardScoreDomain

public actor MatchesRepositoryMock: MatchesRepositoryProtocol {
    public private(set) var receivedMatch: Domain.NewMatchModel?

    public init() {}

    public func addMatch(_ match: Domain.NewMatchModel) async throws {
        receivedMatch = match
    }
}
