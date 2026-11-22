//
//  GetGameStatsUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 21/11/2026.
//

import Foundation

public protocol GetGameStatsUseCaseProtocol: Sendable {
    func callAsFunction(game: Domain.GameModel) async throws -> Domain.GameStatsModel
}

public struct GetGameStatsUseCase {
    public static let defaultMinimumMatchesForWinRate = 3

    private let repository: MatchesRepositoryProtocol
    private let minimumMatchesForWinRate: Int

    public init(
        repository: MatchesRepositoryProtocol,
        minimumMatchesForWinRate: Int = Self.defaultMinimumMatchesForWinRate
    ) {
        self.repository = repository
        self.minimumMatchesForWinRate = minimumMatchesForWinRate
    }
}

extension GetGameStatsUseCase: GetGameStatsUseCaseProtocol {
    public func callAsFunction(game: Domain.GameModel) async throws -> Domain.GameStatsModel {
        let matches = try await repository.getMatches(for: game)
            .sorted { $0.playedAt < $1.playedAt }
        let records = playerRecords(from: matches)
        let participants = matches.flatMap(\.participants)
        let qualified = records.filter { $0.played >= minimumMatchesForWinRate }
        let underplayed = records.filter { $0.played < minimumMatchesForWinRate }
        let bestWinRates = bestRates(in: qualified)

        return Domain.GameStatsModel(
            timesPlayed: matches.count,
            averageScore: averageScore(of: participants),
            maxScores: leaders(maxScores(of: participants)),
            wins: values(records, \.wins).sorted(by: ranking),
            topWinners: leaders(values(records, \.wins)),
            bestWinRates: bestWinRates,
            underplayedWinRates: bestRates(in: underplayed, beating: bestWinRates.first),
            longestWinStreaks: leaders(values(records, \.longestStreak)),
            mostLosses: leaders(values(records, \.losses))
        )
    }
}

private struct PlayerRecord {
    let player: Domain.PlayerModel
    var played = 0
    var wins = 0
    var currentStreak = 0
    var longestStreak = 0

    var losses: Int { played - wins }

    var rate: Domain.GameStatsModel.PlayerRate {
        Domain.GameStatsModel.PlayerRate(
            player: player,
            wins: wins,
            played: played
        )
    }

    mutating func register(isWinner: Bool) {
        played += 1
        if isWinner {
            wins += 1
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
        } else {
            currentStreak = 0
        }
    }
}

private extension GetGameStatsUseCase {
    typealias PlayerValue = Domain.GameStatsModel.PlayerValue
    typealias PlayerRate = Domain.GameStatsModel.PlayerRate

    func playerRecords(from matches: [Domain.MatchResultModel]) -> [PlayerRecord] {
        var records: [Domain.PlayerModel: PlayerRecord] = [:]
        for participant in matches.flatMap(\.participants) {
            records[participant.player, default: PlayerRecord(player: participant.player)]
                .register(isWinner: participant.isWinner)
        }
        return Array(records.values)
    }

    func averageScore(of participants: [Domain.MatchResultModel.Participant]) -> Double? {
        guard !participants.isEmpty else { return nil }

        let total = participants.reduce(0) { $0 + $1.score }
        return Double(total) / Double(participants.count)
    }

    func maxScores(of participants: [Domain.MatchResultModel.Participant]) -> [PlayerValue] {
        var best: [Domain.PlayerModel: Int] = [:]
        for participant in participants {
            best[participant.player] = max(best[participant.player] ?? participant.score, participant.score)
        }
        return best.map { PlayerValue(player: $0.key, value: $0.value) }
    }

    func values(_ records: [PlayerRecord], _ keyPath: KeyPath<PlayerRecord, Int>) -> [PlayerValue] {
        records
            .filter { $0[keyPath: keyPath] > 0 }
            .map { PlayerValue(player: $0.player, value: $0[keyPath: keyPath]) }
    }

    func leaders(_ values: [PlayerValue]) -> [PlayerValue] {
        guard let top = values.map(\.value).max() else { return [] }

        return values
            .filter { $0.value == top }
            .sorted { $0.player.name < $1.player.name }
    }

    func ranking(_ lhs: PlayerValue, _ rhs: PlayerValue) -> Bool {
        if lhs.value != rhs.value { return lhs.value > rhs.value }
        return lhs.player.name < rhs.player.name
    }

    func bestRates(in records: [PlayerRecord], beating reference: PlayerRate? = nil) -> [PlayerRate] {
        let rates = records
            .filter { $0.wins > 0 }
            .map(\.rate)
        guard let best = rates.max(by: isWorse) else { return [] }

        if let reference, compareRate(best, reference) != .orderedDescending {
            return []
        }

        return rates
            .filter { compareRate($0, best) == .orderedSame && $0.played == best.played }
            .sorted { $0.player.name < $1.player.name }
    }

    func isWorse(_ lhs: PlayerRate, _ rhs: PlayerRate) -> Bool {
        switch compareRate(lhs, rhs) {
        case .orderedAscending: true
        case .orderedDescending: false
        case .orderedSame: lhs.played < rhs.played
        }
    }

    func compareRate(_ lhs: PlayerRate, _ rhs: PlayerRate) -> ComparisonResult {
        let left = lhs.wins * rhs.played
        let right = rhs.wins * lhs.played
        if left < right { return .orderedAscending }
        if left > right { return .orderedDescending }
        return .orderedSame
    }
}
