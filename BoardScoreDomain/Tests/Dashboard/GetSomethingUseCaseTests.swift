//
//  GetSomethingUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 23/10/2026.
//

import Testing
@testable import BoardScoreDomain

struct GetSomethingUseCaseTests {
    let repositoryMock = DashboardRepositoryMock()

    @Test
    func doSomething() {
        let sut = DefaultGetSomethingUseCase(repository: repositoryMock)
        #expect(true)
    }
}
