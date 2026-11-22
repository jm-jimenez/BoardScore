//
//  GetGameStatsUseCaseTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 21/11/2026.
//

import Foundation
import Testing
import BoardScoreDomainMocks
@testable import BoardScoreDomain

struct GetGameStatsUseCaseTests {
    let sut: GetGameStatsUseCase
    let repository: MatchesRepositoryMock
    let game = Domain.GameModel.mock(name: "Azul")
    let alice = Domain.PlayerModel(name: "Alice")
    let bob = Domain.PlayerModel(name: "Bob")
    let carol = Domain.PlayerModel(name: "Carol")

    init() {
        repository = MatchesRepositoryMock()
        sut = GetGameStatsUseCase(repository: repository)
    }

    @Test
    func noMatches_ShouldReturnEmptyStats() async throws {
        let result = try await stats([])

        #expect(result.timesPlayed == 0)
        #expect(result.averageScore == nil)
        #expect(result.maxScores.isEmpty)
        #expect(result.wins.isEmpty)
        #expect(result.topWinners.isEmpty)
        #expect(result.bestWinRates.isEmpty)
        #expect(result.underplayedWinRates.isEmpty)
        #expect(result.longestWinStreaks.isEmpty)
        #expect(result.mostLosses.isEmpty)
    }

    @Test
    func shouldAskRepositoryForTheGame() async throws {
        _ = try await sut(game: game)

        #expect(await repository.receivedGame == game)
    }

    @Test
    func shouldCountMatchesAndAverageEveryScore() async throws {
        let result = try await stats([
            match(1, .win(alice, 30), .loss(bob, 10)),
            match(2, .win(bob, 50), .loss(alice, 20), .loss(carol, 40))
        ])

        #expect(result.timesPlayed == 2)
        #expect(result.averageScore == 30)
    }

    @Test
    func maxScores_ShouldListEveryTiedPlayerOnce() async throws {
        let result = try await stats([
            match(1, .win(alice, 80), .loss(bob, 80)),
            match(2, .win(alice, 80), .loss(carol, 10))
        ])

        #expect(result.maxScores == [value(alice, 80), value(bob, 80)])
    }

    @Test
    func wins_ShouldCountSharedWinsAndSortByWinsThenName() async throws {
        let result = try await stats([
            match(1, .win(bob), .win(carol)),
            match(2, .win(carol), .loss(alice)),
            match(3, .win(alice), .loss(bob)),
            match(4, .loss(alice), .loss(bob))
        ])

        #expect(result.wins == [value(carol, 2), value(alice, 1), value(bob, 1)])
        #expect(result.topWinners == [value(carol, 2)])
    }

    @Test
    func topWinners_WhenTied_ShouldReturnEveryTiedPlayer() async throws {
        let result = try await stats([
            match(1, .win(bob), .loss(alice)),
            match(2, .win(alice), .loss(bob))
        ])

        #expect(result.topWinners == [value(alice, 1), value(bob, 1)])
    }

    @Test
    func mostLosses_ShouldReturnEveryTiedPlayer() async throws {
        let result = try await stats([
            match(1, .win(carol), .loss(alice), .loss(bob)),
            match(2, .win(carol), .loss(alice), .loss(bob))
        ])

        #expect(result.mostLosses == [value(alice, 2), value(bob, 2)])
    }

    @Test
    func longestWinStreak_ShouldIgnoreMatchesNotPlayedButBreakOnLosses() async throws {
        let result = try await stats([
            match(1, .win(alice), .loss(bob)),
            match(2, .win(bob), .loss(carol)),
            match(3, .win(alice), .loss(carol)),
            match(4, .loss(alice), .win(carol)),
            match(5, .win(alice), .loss(bob))
        ])

        #expect(result.longestWinStreaks == [value(alice, 2)])
    }

    @Test
    func longestWinStreak_ShouldFollowPlayedAtOrder() async throws {
        let result = try await stats([
            match(3, .win(alice), .loss(bob)),
            match(1, .win(alice), .loss(bob)),
            match(2, .loss(alice), .win(bob))
        ])

        #expect(result.longestWinStreaks == [value(alice, 1), value(bob, 1)])
    }

    @Test
    func bestWinRate_ShouldOnlyConsiderPlayersWithMinimumMatches() async throws {
        let result = try await stats([
            match(1, .win(alice), .loss(bob)),
            match(2, .win(alice), .loss(bob)),
            match(3, .loss(alice), .win(bob)),
            match(4, .win(carol), .loss(bob))
        ])

        #expect(result.bestWinRates == [rate(alice, 2, 3)])
        #expect(result.underplayedWinRates == [rate(carol, 1, 1)])
    }

    @Test
    func bestWinRate_WhenRatesTie_ShouldPreferMorePlayedMatches() async throws {
        let result = try await stats([
            match(1, .win(alice), .loss(bob)),
            match(2, .win(alice), .win(bob)),
            match(3, .loss(alice), .win(bob)),
            match(4, .win(bob)),
            match(5, .win(bob)),
            match(6, .loss(bob))
        ])

        #expect(result.bestWinRates == [rate(bob, 4, 6)])
    }

    @Test
    func bestWinRate_WhenSameRateAndMatches_ShouldReturnEveryTiedPlayer() async throws {
        let result = try await stats([
            match(1, .win(alice), .win(bob)),
            match(2, .win(alice), .win(bob)),
            match(3, .loss(alice), .loss(bob), .win(carol))
        ])

        #expect(result.bestWinRates == [rate(alice, 2, 3), rate(bob, 2, 3)])
    }

    @Test
    func underplayedWinRate_WhenNotBetterThanBest_ShouldBeEmpty() async throws {
        let result = try await stats([
            match(1, .win(alice)),
            match(2, .win(alice)),
            match(3, .win(alice), .loss(carol)),
            match(4, .win(carol))
        ])

        #expect(result.bestWinRates == [rate(alice, 3, 3)])
        #expect(result.underplayedWinRates.isEmpty)
    }

    @Test
    func underplayedWinRate_WhenNobodyReachesMinimum_ShouldShowBestUnderplayed() async throws {
        let result = try await stats([
            match(1, .win(alice), .loss(bob)),
            match(2, .win(bob))
        ])

        #expect(result.bestWinRates.isEmpty)
        #expect(result.underplayedWinRates == [rate(alice, 1, 1)])
    }

    @Test
    func winRates_ShouldIgnorePlayersWithoutWins() async throws {
        let result = try await stats([
            match(1, .loss(alice), .loss(bob)),
            match(2, .loss(alice), .loss(bob)),
            match(3, .loss(alice), .loss(bob))
        ])

        #expect(result.bestWinRates.isEmpty)
        #expect(result.underplayedWinRates.isEmpty)
        #expect(result.timesPlayed == 3)
    }

    @Test
    func minimumMatches_ShouldBeConfigurable() async throws {
        let matches = [
            match(1, .win(alice), .loss(bob)),
            match(2, .loss(alice), .win(bob)),
            match(3, .win(carol), .loss(bob))
        ]

        let relaxedSut = GetGameStatsUseCase(repository: repository, minimumMatchesForWinRate: 1)

        let strict = try await stats(matches)
        let relaxed = try await relaxedSut(game: game)

        #expect(strict.bestWinRates == [rate(bob, 1, 3)])
        #expect(strict.underplayedWinRates == [rate(carol, 1, 1)])
        #expect(relaxed.bestWinRates == [rate(carol, 1, 1)])
        #expect(relaxed.underplayedWinRates.isEmpty)
        #expect(GetGameStatsUseCase.defaultMinimumMatchesForWinRate == 3)
    }

    @Test
    func playerRate_ShouldComputeRate() {
        #expect(rate(alice, 1, 4).rate == 0.25)
        #expect(rate(alice, 0, 0).rate == 0)
    }
}

private extension GetGameStatsUseCaseTests {
    func stats(_ matches: [Domain.MatchResultModel]) async throws -> Domain.GameStatsModel {
        await repository.setMatches(matches)
        return try await sut(game: game)
    }

    func match(_ order: Int, _ participants: Domain.MatchResultModel.Participant...) -> Domain.MatchResultModel {
        .mock(playedAt: Date(timeIntervalSince1970: TimeInterval(order)), participants: participants)
    }

    func value(_ player: Domain.PlayerModel, _ value: Int) -> Domain.GameStatsModel.PlayerValue {
        Domain.GameStatsModel.PlayerValue(player: player, value: value)
    }

    func rate(_ player: Domain.PlayerModel, _ wins: Int, _ played: Int) -> Domain.GameStatsModel.PlayerRate {
        Domain.GameStatsModel.PlayerRate(player: player, wins: wins, played: played)
    }
}
