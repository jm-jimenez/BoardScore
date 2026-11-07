//
//  TopWinnersMapperTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 27/10/2026.
//

import Testing
@testable import BoardScorePresentation

struct TopWinnersMapperTests {
    let sut: TopWinnersMapper

    init() {
        sut = TopWinnersMapper()
    }

    @Test
    func map_whenDomainIsNil_CountShouldBeZero() {
        let result = sut.map(nil)
        #expect(result.items.count == 0)
    }
}
