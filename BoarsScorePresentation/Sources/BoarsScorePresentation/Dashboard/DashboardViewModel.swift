//
//  DashboardViewModel.swift
//  BoarsScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI
import BoardScoreDomain

protocol DashboardViewModelProtocol: ObservableObject {
    var helloText: String { get }
    func onAppear()
}

@Observable
class DashboardViewModel {
    var helloText: String = ""
}

extension DashboardViewModel: DashboardViewModelProtocol {
    func onAppear() {
        _ = DefaultGetSomethingUseCase()
        helloText = "Hello miarma"
    }
}
