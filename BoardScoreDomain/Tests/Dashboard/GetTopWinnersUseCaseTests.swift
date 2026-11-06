//
//  GetTopWinnersUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 26/10/2026.
//

import Testing
@testable import BoardScoreDomain

struct GetTopWinnersUseCaseTests {
    let sut = GetTopWinnersUseCase()

    @Test
    func whenCalled_ResultMustBeCorrect() async throws {
        let result = try await sut()
        #expect(result.count == 2)
    }
}
