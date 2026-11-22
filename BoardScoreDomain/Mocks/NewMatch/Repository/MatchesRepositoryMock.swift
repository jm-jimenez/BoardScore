//
//  MatchesRepositoryMock.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import BoardScoreDomain

public actor MatchesRepositoryMock: MatchesRepositoryProtocol {
    public private(set) var receivedMatch: Domain.NewMatchModel?
    public private(set) var receivedGame: Domain.GameModel?

    public private(set) var matches: [Domain.MatchResultModel] = []

    public init() {}

    public func setMatches(_ newValue: [Domain.MatchResultModel]) {
        matches = newValue
    }

    public func addMatch(_ match: Domain.NewMatchModel) async throws {
        receivedMatch = match
    }

    public func getMatches(for game: Domain.GameModel) async throws -> [Domain.MatchResultModel] {
        receivedGame = game
        return matches
    }
}
