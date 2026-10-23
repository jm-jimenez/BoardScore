//
//  DashboardViewModel.swift
//  BoarsScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI
import BoardScoreDomain

protocol DashboardViewModelProtocol: ObservableObject {
    func onAppear()
    func onDisappear()

    var disappearCalled: Bool { get }
}

@Observable
class DashboardViewModel {
    var disappearCalled: Bool = false
}

extension DashboardViewModel: DashboardViewModelProtocol {
    func onAppear() {
        _ = DefaultGetSomethingUseCase()
    }

    func onDisappear() {
        disappearCalled = true
    }
}
