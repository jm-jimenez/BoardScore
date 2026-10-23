//
//  DashboardFactoryTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import Testing
@testable import BoardScorePresentation

struct DashboardFactoryTests {

    @MainActor @Test
    func dashboardFactory_shouldBuildView() {
        let view = DashboardFactory.build()
        #expect(view is DashboardView<DashboardViewModel>)
    }
}
