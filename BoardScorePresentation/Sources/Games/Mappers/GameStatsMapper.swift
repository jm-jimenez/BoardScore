//
//  GameStatsMapper.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import Foundation
import BoardScoreDomain

protocol GameStatsMapperProtocol {
    func map(_ stats: Domain.GameStatsModel) -> GameStatsViewData
}

struct GameStatsMapper: GameStatsMapperProtocol {
    private let locale: Locale

    init(locale: Locale = .current) {
        self.locale = locale
    }

    func map(_ stats: Domain.GameStatsModel) -> GameStatsViewData {
        GameStatsViewData(
            winners: WinnersChartView.ViewData(slices: slices(stats)),
            stats: GameStatsView.ViewData(rows: rows(stats))
        )
    }
}

private extension GameStatsMapper {
    typealias Row = GameStatRowView.ViewData
    typealias Entry = GameStatRowView.ViewData.Entry

    func slices(_ stats: Domain.GameStatsModel) -> [WinnersChartView.ViewData.Slice] {
        stats.wins.map { winner in
            WinnersChartView.ViewData.Slice(
                name: winner.player.name,
                wins: winner.value,
                detail: "\(winner.value) · \(percent(winner.value, of: stats.timesPlayed))"
            )
        }
    }

    func rows(_ stats: Domain.GameStatsModel) -> [Row] {
        let played = stats.timesPlayed
        let rows: [Row?] = [
            Row(title: "Times played".localized, value: "\(played)"),
            row("Highest score", entries(stats.maxScores)),
            stats.averageScore.map { Row(title: "Average score".localized, value: number($0)) },
            row("Top winner", stats.topWinners.map {
                Entry(player: $0.player.name, value: "\($0.value) / \(played) · \(percent($0.value, of: played))")
            }),
            row(
                "Best win rate",
                stats.bestWinRates.map { rateEntry($0, isSecondary: false) }
                    + stats.underplayedWinRates.map { rateEntry($0, isSecondary: true) }
            ),
            row("Longest win streak", entries(stats.longestWinStreaks)),
            row("Most losses", entries(stats.mostLosses))
        ]
        return rows.compactMap { $0 }
    }

    func row(_ title: String, _ entries: [Entry]) -> Row? {
        entries.isEmpty ? nil : Row(title: title.localized, entries: entries)
    }

    func entries(_ values: [Domain.GameStatsModel.PlayerValue]) -> [Entry] {
        values.map { Entry(player: $0.player.name, value: "\($0.value)") }
    }

    func rateEntry(_ rate: Domain.GameStatsModel.PlayerRate, isSecondary: Bool) -> Entry {
        Entry(
            player: rate.player.name,
            value: "\(percent(rate.wins, of: rate.played)) · \(rate.wins) / \(rate.played)",
            note: isSecondary ? onlyPlayed(rate.played) : nil,
            isSecondary: isSecondary
        )
    }

    func percent(_ value: Int, of total: Int) -> String {
        let ratio = total == 0 ? 0 : Double(value) / Double(total)
        return ratio.formatted(.percent.precision(.fractionLength(0)).locale(locale))
    }

    func number(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(0...1)).locale(locale))
    }

    func onlyPlayed(_ matches: Int) -> String {
        String.localizedStringWithFormat("Only played %lld matches".localized, matches)
    }
}
