//
//  NewMatchFactoryTests.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import Testing
@testable import BoardScorePresentation

struct NewMatchFactoryTests {

    @MainActor @Test
    func newMatchFactory_ShouldBuildView() {
        let view = NewMatchFactory.build(dependencies: DashboardExternalDependenciesTest()) {}
        #expect(view is NewMatchView<NewMatchViewModel>)
    }
}
