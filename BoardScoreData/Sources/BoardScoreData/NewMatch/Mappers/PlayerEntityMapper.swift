//
//  PlayerEntityMapper.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 17/11/2026.
//

import BoardScoreDomain

protocol PlayerEntityMapperProtocol: Sendable {
    func map(_ entity: PlayerEntity) -> Domain.PlayerModel
}

struct PlayerEntityMapper: PlayerEntityMapperProtocol {
    func map(_ entity: PlayerEntity) -> Domain.PlayerModel {
        Domain.PlayerModel(id: entity.id, name: entity.name)
    }
}
