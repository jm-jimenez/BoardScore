//
//  LastGamesMapper.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 26/10/2026.
//

import Foundation
import BoardScoreDomain

protocol LastGamesMapperProtocol {
    func map(_ domainModels: [Domain.GetLastGamesModel]?) -> LastGamesView.ViewData
}

struct LastGamesMapper: LastGamesMapperProtocol {
    func map(_ domainModels: [Domain.GetLastGamesModel]?) -> LastGamesView.ViewData {
        guard let domainModels else {
            return LastGamesView.ViewData(items: [])
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"

        let items = domainModels.map {
            LastGamesView.ViewData.LastGame(
                name: $0.name,
                winner: $0.winner,
                date: dateFormatter.string(from: $0.date)
            )
        }

        return LastGamesView.ViewData(items: items)
    }
}
