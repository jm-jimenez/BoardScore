//
//  GameStatsMapperTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

import Foundation
import Testing
import BoardScoreDomain
import BoardScoreDomainMocks
@testable import BoardScorePresentation

struct GameStatsMapperTests {
    let sut = GameStatsMapper(locale: Locale(identifier: "en_US"))
    let mercedes = Domain.PlayerModel.mock(name: "Mercedes")
    let dani = Domain.PlayerModel.mock(name: "Dani")
    let lucia = Domain.PlayerModel.mock(name: "Lucía")

    @Test
    func map_ShouldBuildChartSlicesWithAbsolutePercentages() {
        let result = sut.map(.mock(
            timesPlayed: 8,
            wins: [value(mercedes, 4), value(dani, 3), value(lucia, 2)]
        ))

        #expect(result.winners.slices == [
            .init(name: "Mercedes", wins: 4, detail: "4 · 50%"),
            .init(name: "Dani", wins: 3, detail: "3 · 38%"),
            .init(name: "Lucía", wins: 2, detail: "2 · 25%")
        ])
    }

    @Test
    func map_ShouldGroupTiedPlayersUnderOneTitle() {
        let result = sut.map(Domain.GameStatsModel(
            timesPlayed: 4,
            averageScore: 52.5,
            maxScores: [value(dani, 90), value(mercedes, 90)],
            wins: [],
            topWinners: [value(mercedes, 3)],
            bestWinRates: [rate(mercedes, 3, 4)],
            underplayedWinRates: [rate(lucia, 1, 1)],
            longestWinStreaks: [value(dani, 2), value(mercedes, 2)],
            mostLosses: [value(dani, 3)]
        ))

        #expect(result.stats.rows == [
            valueRow("Times played", "4"),
            row("Highest score", [entry("Dani", "90"), entry("Mercedes", "90")]),
            valueRow("Average score", "52.5"),
            row("Top winner", [entry("Mercedes", "3 / 4 · 75%")]),
            row("Best win rate", [
                entry("Mercedes", "75% · 3 / 4"),
                GameStatRowView.ViewData.Entry(
                    player: "Lucía",
                    value: "100% · 1 / 1",
                    note: String.localizedStringWithFormat("Only played %lld matches".localized, 1),
                    isSecondary: true
                )
            ]),
            row("Longest win streak", [entry("Dani", "2"), entry("Mercedes", "2")]),
            row("Most losses", [entry("Dani", "3")])
        ])
    }

    @Test
    func map_WhenOnlyUnderplayedRate_ShouldKeepTheRowWithTheSecondaryEntry() {
        let result = sut.map(.mock(bestWinRates: [], underplayedWinRates: [rate(lucia, 2, 2)]))
        let winRate = result.stats.rows.first { $0.title == "Best win rate".localized }

        #expect(winRate?.entries.map(\.player) == ["Lucía"])
        #expect(winRate?.entries.first?.isSecondary == true)
        #expect(winRate?.value == nil)
    }

    @Test
    func map_WithoutScores_ShouldSkipAverageRow() {
        let result = sut.map(Domain.GameStatsModel(
            timesPlayed: 0,
            averageScore: nil,
            maxScores: [],
            wins: [],
            topWinners: [],
            bestWinRates: [],
            underplayedWinRates: [],
            longestWinStreaks: [],
            mostLosses: []
        ))

        #expect(result.stats.rows == [valueRow("Times played", "0")])
        #expect(result.winners.slices.isEmpty)
    }

    @Test
    func map_ShouldRoundAverageToOneDecimal() {
        let whole = sut.map(.mock(averageScore: 30))
        let decimal = sut.map(.mock(averageScore: 41.26))

        #expect(whole.stats.rows.contains(valueRow("Average score", "30")))
        #expect(decimal.stats.rows.contains(valueRow("Average score", "41.3")))
    }

    @Test
    func onlyPlayedNote_ShouldIncludeTheMatchCount() {
        let result = sut.map(.mock(underplayedWinRates: [rate(lucia, 2, 2)]))
        let note = result.stats.rows.flatMap(\.entries).first { $0.isSecondary }?.note

        #expect(note?.contains("2") == true)
    }
}

private extension GameStatsMapperTests {
    func value(_ player: Domain.PlayerModel, _ value: Int) -> Domain.GameStatsModel.PlayerValue {
        Domain.GameStatsModel.PlayerValue(player: player, value: value)
    }

    func rate(_ player: Domain.PlayerModel, _ wins: Int, _ played: Int) -> Domain.GameStatsModel.PlayerRate {
        Domain.GameStatsModel.PlayerRate(player: player, wins: wins, played: played)
    }

    func valueRow(_ title: String, _ value: String) -> GameStatRowView.ViewData {
        GameStatRowView.ViewData(title: title.localized, value: value)
    }

    func row(_ title: String, _ entries: [GameStatRowView.ViewData.Entry]) -> GameStatRowView.ViewData {
        GameStatRowView.ViewData(title: title.localized, entries: entries)
    }

    func entry(_ player: String, _ value: String) -> GameStatRowView.ViewData.Entry {
        GameStatRowView.ViewData.Entry(player: player, value: value)
    }
}
