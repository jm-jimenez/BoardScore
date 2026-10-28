//
//  TopWinnersMapper.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 26/10/2026.
//

import BoardScoreDomain

protocol TopWinnersMapperProtocol {
    func map(_ domainModels: [Domain.GetTopWinnersModel]?) -> TopWinnersView.ViewData
}

struct TopWinnersMapper: TopWinnersMapperProtocol {
    func map(_ domainModels: [Domain.GetTopWinnersModel]?) -> TopWinnersView.ViewData {
        guard let domainModels else {
            return TopWinnersView.ViewData(items: [])
        }
        let items = domainModels.map {
            TopWinnersView.ViewData.WinnerSummary(
                name: $0.name,
                lastGame: $0.lastGameWin,
                winsLoses: "\($0.wins) / \($0.loses)")
        }

        return TopWinnersView.ViewData(items: items)
    }
}
