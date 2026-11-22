//
//  AddMatchUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct AddMatchUseCaseTests {
    let sut: AddMatchUseCase
    let repository: MatchesRepositoryMock

    init() {
        repository = MatchesRepositoryMock()
        sut = AddMatchUseCase(repository: repository)
    }

    @Test
    func whenCalled_ShouldSendMatchToRepository() async throws {
        let match = Domain.NewMatchModel.mock(durationMinutes: 30)

        try await sut(match)

        let receivedMatch = await repository.receivedMatch
        #expect(receivedMatch == match)
    }
}
