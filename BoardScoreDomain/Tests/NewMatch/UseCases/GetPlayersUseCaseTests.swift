//
//  GetPlayersUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct GetPlayersUseCaseTests {
    let sut: GetPlayersUseCase
    let repository: PlayersRepositoryMock
    let players: [Domain.PlayerModel]

    init() {
        players = [.mock(name: "Dani"), .mock(name: "Mercedes")]
        repository = PlayersRepositoryMock(players: players)
        sut = GetPlayersUseCase(repository: repository)
    }

    @Test
    func whenCalled_ShouldReturnRepositoryPlayers() async throws {
        let result = try await sut()

        #expect(result == players)
    }
}
