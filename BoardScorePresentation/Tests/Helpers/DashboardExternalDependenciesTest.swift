//
//  DashboardExternalDependenciesTest.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 09/11/2026.
//

import BoardScoreDomain
import BoardScoreDomainMocks
@testable import BoardScorePresentation

struct DashboardExternalDependenciesTest: DashboardExternalDependencies {
    func resolve() -> DashboardRepositoryProtocol {
        DashboardRepositoryMock()
    }
}
