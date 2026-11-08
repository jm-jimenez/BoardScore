//
//  GetLastGamesMapperTests.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 07/11/2026.
//

import Foundation
import Testing
import BoardScoreDomain
import BoardScoreDataMocks

@testable import BoardScoreData

struct GetLastGamesMapperTests {
    let sut: GetLastGamesMapper

    init() {
        sut = GetLastGamesMapper()
    }

    @Test
    func map() {
        let data = [BoardScoreData.Data.GetLastGamesModel.mock()]
        let expected = Domain.GetLastGamesModel(name: "test", winner: "test", date: Date())
        let result = sut.map(data)

        #expect(result.count == 1)
        #expect(result[0].name == expected.name)
        #expect(result[0].winner == expected.winner)
    }
}
