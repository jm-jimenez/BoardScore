//
//  GamesPlaceholder.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

extension GameStatsViewData {
    static var placeholder: Self {
        typealias Slice = WinnersChartView.ViewData.Slice
        typealias Row = GameStatRowView.ViewData
        typealias Entry = GameStatRowView.ViewData.Entry

        return Self(
            winners: WinnersChartView.ViewData(slices: [
                Slice(name: "Player name", wins: 3, detail: "0 · 00 %"),
                Slice(name: "Player", wins: 2, detail: "0 · 00 %"),
                Slice(name: "Name", wins: 1, detail: "0 · 00 %")
            ]),
            stats: GameStatsView.ViewData(rows: [
                Row(title: "Times played", value: "00"),
                Row(title: "Highest score", entries: [Entry(player: "Player name", value: "000")]),
                Row(title: "Average score", value: "00"),
                Row(title: "Top winner", entries: [Entry(player: "Player", value: "00 / 00 · 00 %")])
            ])
        )
    }
}
