//
//  GetTopWinnersMapperTests.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 09/11/2026.
//

import Testing
import BoardScoreDomain
import BoardScoreDataMocks

@testable import BoardScoreData

struct GetTopWinnersMapperTests {
    let sut: GetTopWinnersMapper

    init() {
        sut = GetTopWinnersMapper()
    }

    @Test
    func map() {
        let data = [BoardScoreData.Data.GetTopWinnersModel.mock(
            name: "Mercedes",
            lastGameWin: "Wingspan",
            wins: 13,
            losses: 6
        )]
        let result = sut.map(data)

        #expect(result.count == 1)
        #expect(result[0].name == "Mercedes")
        #expect(result[0].lastGameWin == "Wingspan")
        #expect(result[0].wins == 13)
        #expect(result[0].losses == 6)
    }
}
