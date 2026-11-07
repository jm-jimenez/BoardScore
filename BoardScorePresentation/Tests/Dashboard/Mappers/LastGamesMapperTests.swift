//
//  LastGamesMapperTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 26/10/2026.
//

import Testing
import BoardScoreDomain
import BoardScoreDomainMocks
@testable import BoardScorePresentation

struct LastGamesMapperTests {
    let sut: LastGamesMapper

    init() {
        sut = LastGamesMapper()
    }

    @Test
    func map_whenDomainIsNil_CountShouldBeZero() {
        let result = sut.map(nil)
        #expect(result.items.count == 0)
    }

    @Test
    func map_whenDomainIsNotEmpty_CountShouldBeCorrect() {
        let items: [Domain.GetLastGamesModel] = [.mock(), .mock()]
        let result = sut.map(items)
        #expect(result.items.count == 2)
    }
}
