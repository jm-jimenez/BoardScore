//
//  GetTopWinnersUseCase.swift
//  BoardScoreDomain
//
//  Created by José María Jiménez on 25/10/2026.
//

public protocol GetTopWinnersUseCaseProtocol: Sendable {
    func callAsFunction() async throws -> [Domain.GetTopWinnersModel]
}

public struct GetTopWinnersUseCase {
    public init() {

    }
}

extension GetTopWinnersUseCase: GetTopWinnersUseCaseProtocol {
    public func callAsFunction() async throws -> [Domain.GetTopWinnersModel] {
        [
            .init(name: "Mercedes",
                  lastGameWin: "Wingspan",
                  wins: 13,
                  losses: 6),
            .init(name: "M@rio",
                  lastGameWin: "Alquimistas",
                  wins: 8,
                  losses: 3)
        ]
    }
}

public extension Domain {
    struct GetTopWinnersModel {
        public let name: String
        public let lastGameWin: String
        public let wins: Int
        public let losses: Int
    }
}
