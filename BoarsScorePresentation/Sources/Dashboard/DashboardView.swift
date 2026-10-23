//
//  DashboardView.swift
//  BoarsScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI

struct DashboardView<ViewModel>: View where ViewModel: DashboardViewModelProtocol {

    @ObservedObject
    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var body: some View {
        ChartView()
            .background { Color.red }
        Text(viewModel.helloText)
            .onAppear {
                viewModel.onAppear()
            }
        Spacer()
    }
}

#if DEBUG

private class DashboardViewModelMock: DashboardViewModelProtocol {
    let helloText: String = "mock"

    func onAppear() {

    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModelMock())
}

#endif
