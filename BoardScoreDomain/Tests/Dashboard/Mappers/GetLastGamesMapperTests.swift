//
//  GetLastGamesMapperTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 07/11/2026.
//

import Foundation
import Testing
import BoardScoreData

@testable import BoardScoreDomain

struct GetLastGamesMapperTests {
    let sut: GetLastGamesMapper

    init() {
        sut = GetLastGamesMapper()
    }

    @Test
    func map() {
        let data = [Data.GetLastGamesModel.mock()]
        let expected = Domain.GetLastGamesModel(name: "test", winner: "test", date: Date())
        let result = sut.map(data)

        #expect(result.count == 1)
        #expect(result[0].name == expected.name)
        #expect(result[0].winner == expected.winner)
    }
}
