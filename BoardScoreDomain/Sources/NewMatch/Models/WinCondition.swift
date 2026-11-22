//
//  WinCondition.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

public extension Domain {
    enum WinCondition: Sendable, Hashable, CaseIterable {
        case highestScore
        case lowestScore
    }
}
