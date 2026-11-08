//
//  GetLastGamesUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 23/10/2026.
//

import Testing
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct GetLastGamesUseCaseTests {
    let sut: GetLastGamesUseCase
    let repository: DashboardRepositoryProtocol

    init() {
        repository = DashboardRepositoryMock()
        sut = GetLastGamesUseCase(repository: repository)
    }

    @Test
    func whenCalled_ResultMustBeCorrect() async throws {
        let result = try await sut()
        #expect(result.count == 0)
    }

}
