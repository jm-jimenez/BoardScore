//
//  GameEntityMapper.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 12/11/2026.
//

import BoardScoreDomain

protocol GameEntityMapperProtocol: Sendable {
    func map(_ entity: GameEntity) -> Domain.GameModel
}

struct GameEntityMapper: GameEntityMapperProtocol {
    func map(_ entity: GameEntity) -> Domain.GameModel {
        Domain.GameModel(
            id: entity.id,
            name: entity.name,
            winCondition: entity.winCondition.domain,
            scoreables: entity.scoreables
                .filter { !$0.isArchived }
                .sorted { $0.sortOrder < $1.sortOrder }
                .map { Domain.ScoreableModel(id: $0.id, name: $0.name) }
        )
    }
}

extension WinCondition {
    init(_ domain: Domain.WinCondition) {
        switch domain {
        case .highestScore: self = .highestScore
        case .lowestScore: self = .lowestScore
        }
    }

    var domain: Domain.WinCondition {
        switch self {
        case .highestScore: .highestScore
        case .lowestScore: .lowestScore
        }
    }
}
