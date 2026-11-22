//
//  AddPlayerUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct AddPlayerUseCaseTests {
    let sut: AddPlayerUseCase
    let repository: PlayersRepositoryMock

    init() {
        repository = PlayersRepositoryMock()
        sut = AddPlayerUseCase(repository: repository)
    }

    @Test
    func whenCalled_ShouldReturnCreatedPlayer() async throws {
        let result = try await sut(.mock(name: "Lucía"))

        #expect(result.name == "Lucía")
    }
}
