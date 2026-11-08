//
//  DashboardFactoryTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import Testing
import BoardScoreDomain
import BoardScoreDomainMocks
@testable import BoardScorePresentation

struct DashboardFactoryTests {

    @MainActor @Test
    func dashboardFactory_shouldBuildView() {
        let view = DashboardFactory.build(dependencies: DashboardExternalDependenciesTest())
        #expect(view is DashboardView<DashboardViewModel>)
    }
}

struct DashboardExternalDependenciesTest: DashboardExternalDependencies {
    func resolve() -> DashboardRepositoryProtocol {
        DashboardRepositoryMock()
    }
}
