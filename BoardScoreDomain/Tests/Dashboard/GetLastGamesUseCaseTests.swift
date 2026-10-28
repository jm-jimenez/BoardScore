//
//  GetLastGamesUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 23/10/2026.
//

import Testing
@testable import BoardScoreDomain

struct GetLastGamesUseCaseTests {
    let sut = GetLastGamesUseCase()

    @Test
    func whenCalled_ResultMustBeCorrect() async throws {
        let result = try await sut()
        #expect(result.count == 2)
    }

}
