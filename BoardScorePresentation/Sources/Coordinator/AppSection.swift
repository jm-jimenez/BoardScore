//
//  AppSection.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 21/11/2026.
//

enum AppSection: CaseIterable, Identifiable {
    case dashboard
    case games
    case players

    var id: Self { self }

    var title: String {
        switch self {
        case .dashboard: "Dashboard".localized
        case .games: "Games".localized
        case .players: "Players".localized
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: "chart.bar.xaxis"
        case .games: "dice"
        case .players: "person.2"
        }
    }
}
