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
}

@Observable
class DashboardViewModel {

}

extension DashboardViewModel: DashboardViewModelProtocol {
    func onAppear() {
        _ = DefaultGetSomethingUseCase()
    }
}
