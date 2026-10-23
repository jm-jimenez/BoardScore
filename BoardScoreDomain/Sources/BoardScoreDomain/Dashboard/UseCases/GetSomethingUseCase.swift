//
//  GetSomethingUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 18/10/2026.
//

import BoardScoreData

public protocol GetSomethingUseCaseProtocol {
    func testFunction() -> Bool
}

public struct DefaultGetSomethingUseCase {
    private let repository: DashboardRepositoryProtocol

    public init(
        repository: DashboardRepositoryProtocol = DefaultDashboardRepository()
    ) {
        self.repository = repository
    }
}

extension DefaultGetSomethingUseCase: GetSomethingUseCaseProtocol {
    public func testFunction() -> Bool {
        return true
    }
}
