//
//  MatchEntityMapper.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 21/11/2026.
//

import BoardScoreDomain

protocol MatchEntityMapperProtocol: Sendable {
    func map(_ entity: MatchEntity) -> Domain.MatchResultModel
}

struct MatchEntityMapper: MatchEntityMapperProtocol {
    private let playerMapper: PlayerEntityMapperProtocol

    init(playerMapper: PlayerEntityMapperProtocol = PlayerEntityMapper()) {
        self.playerMapper = playerMapper
    }

    func map(_ entity: MatchEntity) -> Domain.MatchResultModel {
        Domain.MatchResultModel(
            playedAt: entity.playedAt,
            participants: entity.participants
                .sorted { $0.turnOrder < $1.turnOrder }
                .compactMap { participant in
                    guard let player = participant.player else { return nil }

                    return Domain.MatchResultModel.Participant(
                        player: playerMapper.map(player),
                        score: participant.totalScore,
                        isWinner: participant.isWinner
                    )
                }
        )
    }
}
