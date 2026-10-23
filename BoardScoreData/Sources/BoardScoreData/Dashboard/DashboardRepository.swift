//
//  DashboardRepository.swift
//  BoardScoreData
//
//  Created by José María Jiménez on 18/10/2026.
//

public protocol DashboardRepositoryProtocol {}

public struct DefaultDashboardRepository {
    public init() { }
}

extension DefaultDashboardRepository: DashboardRepositoryProtocol {

}
