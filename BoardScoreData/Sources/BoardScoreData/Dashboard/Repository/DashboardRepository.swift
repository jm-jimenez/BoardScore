//
//  DashboardRepository.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 18/10/2026.
//

import Foundation
import SwiftData
import BoardScoreDomain

public actor DefaultDashboardRepository: ModelActor {
    enum C {
        static let lastGamesLimit = 10
        static let topWinnersLimit = 10
    }

    public nonisolated let modelExecutor: any ModelExecutor
    public nonisolated let modelContainer: ModelContainer

    private let getLastGamesMapper: GetLastGamesMapperProtocol
    private let getTopWinnersMapper: GetTopWinnersMapperProtocol

    public init(
        modelContainer: ModelContainer,
        getLastGamesMapper: GetLastGamesMapperProtocol = GetLastGamesMapper(),
        getTopWinnersMapper: GetTopWinnersMapperProtocol = GetTopWinnersMapper()
    ) {
        self.modelContainer = modelContainer
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: ModelContext(modelContainer))
        self.getLastGamesMapper = getLastGamesMapper
        self.getTopWinnersMapper = getTopWinnersMapper
    }
}

extension DefaultDashboardRepository: DashboardRepositoryProtocol {
    public func getLastGames() async throws -> [Domain.GetLastGamesModel] {
        var descriptor = FetchDescriptor<MatchEntity>(
            sortBy: [SortDescriptor(\.playedAt, order: .reverse)]
        )
        descriptor.fetchLimit = C.lastGamesLimit

        let games = try modelContext.fetch(descriptor).map { match in
            Data.GetLastGamesModel(
                name: match.game?.name ?? "",
                winner: match.winners.compactMap { $0.player?.name }.joined(separator: ", "),
                date: match.playedAt
            )
        }
        return getLastGamesMapper.map(games)
    }

    public func getTopWinners() async throws -> [Domain.GetTopWinnersModel] {
        let descriptor = FetchDescriptor<PlayerEntity>(
            predicate: #Predicate { !$0.isArchived }
        )

        let winners = try modelContext.fetch(descriptor)
            .compactMap(PlayerStats.init)
            .sorted(by: PlayerStats.ranking)
            .prefix(C.topWinnersLimit)
            .map(\.model)

        return getTopWinnersMapper.map(Array(winners))
    }
}

private struct PlayerStats {
    let model: Data.GetTopWinnersModel

    init?(player: PlayerEntity) {
        let participations = player.participations
        let wins = participations.filter(\.isWinner)
        guard !wins.isEmpty else { return nil }

        let lastWin = wins.max { lhs, rhs in
            (lhs.match?.playedAt ?? .distantPast) < (rhs.match?.playedAt ?? .distantPast)
        }

        model = Data.GetTopWinnersModel(
            name: player.name,
            lastGameWin: lastWin?.match?.game?.name ?? "",
            wins: wins.count,
            losses: participations.count - wins.count
        )
    }

    static func ranking(_ lhs: PlayerStats, _ rhs: PlayerStats) -> Bool {
        if lhs.model.wins != rhs.model.wins { return lhs.model.wins > rhs.model.wins }
        if lhs.model.losses != rhs.model.losses { return lhs.model.losses < rhs.model.losses }
        return lhs.model.name < rhs.model.name
    }
}
