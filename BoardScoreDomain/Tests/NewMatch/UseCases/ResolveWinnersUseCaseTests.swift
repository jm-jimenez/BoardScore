//
//  ResolveWinnersUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Foundation
import Testing
@testable import BoardScoreDomain

struct ResolveWinnersUseCaseTests {
    let sut = ResolveWinnersUseCase()
    let alice = Domain.PlayerModel(name: "Alice")
    let bob = Domain.PlayerModel(name: "Bob")
    let carol = Domain.PlayerModel(name: "Carol")

    @Test
    func highestScore_ShouldReturnPlayerWithMostPoints() {
        let result = sut(totals: [alice: 10, bob: 25, carol: -3], winCondition: .highestScore)
        #expect(result == [bob])
    }

    @Test
    func lowestScore_ShouldReturnPlayerWithFewestPoints() {
        let result = sut(totals: [alice: 10, bob: 25, carol: -3], winCondition: .lowestScore)
        #expect(result == [carol])
    }

    @Test
    func tie_ShouldReturnAllTiedPlayers() {
        let result = sut(totals: [alice: 20, bob: 20, carol: 5], winCondition: .highestScore)
        #expect(result == [alice, bob])
    }

    @Test
    func noPlayers_ShouldReturnEmpty() {
        let result = sut(totals: [:], winCondition: .highestScore)
        #expect(result.isEmpty)
    }
}
