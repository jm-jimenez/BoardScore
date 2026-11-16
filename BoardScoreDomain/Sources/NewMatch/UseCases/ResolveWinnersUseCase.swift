//
//  ResolveWinnersUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation

public protocol ResolveWinnersUseCaseProtocol: Sendable {
    func callAsFunction(totals: [Domain.PlayerModel: Int], winCondition: Domain.WinCondition) -> Set<Domain.PlayerModel>
}

public struct ResolveWinnersUseCase {
    public init() {}
}

extension ResolveWinnersUseCase: ResolveWinnersUseCaseProtocol {
    public func callAsFunction(
        totals: [Domain.PlayerModel: Int],
        winCondition: Domain.WinCondition
    ) -> Set<Domain.PlayerModel> {
        let best: Int?
        switch winCondition {
        case .highestScore:
            best = totals.values.max()
        case .lowestScore:
            best = totals.values.min()
        }

        guard let best else { return [] }

        return Set(totals.filter { $0.value == best }.keys)
    }
}
