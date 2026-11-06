//
//  GetLastGamesUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 23/10/2026.
//

import Testing
import BoardScoreData
import BoardScoreDataMocks
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct GetLastGamesUseCaseTests {
    let sut: GetLastGamesUseCase
    let repository: DashboardRepositoryProtocol
    let mapper: GetLastGamesMapperProtocol

    init() {
        repository = DashboardRepositoryMock()
        mapper = GetLastGamesMapperMock()
        sut = GetLastGamesUseCase(
            repository: repository,
            mapper: mapper
        )
    }

    @Test
    func whenCalled_ResultMustBeCorrect() async throws {
        let result = try await sut()
        #expect(result.count == 0)
    }

}
