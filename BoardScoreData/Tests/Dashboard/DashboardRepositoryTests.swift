//
//  DashboardRepositoryTests.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 18/10/2026.
//

import Testing
@testable import BoardScoreData

struct DashboardRepositoryTests {

    @Test
    func testInit() {
        let sut = DefaultDashboardRepository()
        #expect(sut != nil)
    }
}
