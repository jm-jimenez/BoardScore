//
//  DashboardViewModelTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import Testing
@testable import BoardScorePresentation

struct DashboardViewModelTests {

    @Test
    func onAppear_TextShouldBeCorrect() async throws {
        let sut = DashboardViewModel()
        sut.onAppear()
    }

    @Test
    func onDisappear_Something() async throws {
        let sut = DashboardViewModel()
        sut.onDisappear()
        #expect(sut.disappearCalled)
    }
}
