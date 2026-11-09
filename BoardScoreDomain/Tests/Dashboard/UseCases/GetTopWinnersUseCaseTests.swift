//
//  GetTopWinnersUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 26/10/2026.
//

import Testing
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct GetTopWinnersUseCaseTests {
    let sut: GetTopWinnersUseCase
    let repository: DashboardRepositoryProtocol

    init() {
        repository = DashboardRepositoryMock()
        sut = GetTopWinnersUseCase(repository: repository)
    }

    @Test
    func whenCalled_ResultMustBeCorrect() async throws {
        let result = try await sut()
        #expect(result.count == 0)
    }
}
