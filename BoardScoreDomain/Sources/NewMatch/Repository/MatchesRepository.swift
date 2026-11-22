//
//  MatchesRepository.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 17/11/2026.
//

public protocol MatchesRepositoryProtocol: Sendable {
    func addMatch(_ match: Domain.NewMatchModel) async throws
    func getMatches(for game: Domain.GameModel) async throws -> [Domain.MatchResultModel]
}
