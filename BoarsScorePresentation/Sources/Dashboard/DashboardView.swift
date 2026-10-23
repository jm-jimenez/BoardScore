//
//  DashboardView.swift
//  BoarsScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI

private enum DashboardViewConstants {
    static let chartPadding: CGFloat = 50
}

struct DashboardView<ViewModel>: View where ViewModel: DashboardViewModelProtocol {

    @ObservedObject
    private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = ObservedObject(initialValue: viewModel)
    }

    var body: some View {
        VStack {
            ChartView()
                .padding(.horizontal, DashboardViewConstants.chartPadding)
            LastGamesView()
            Spacer()
        }
        .background { Color(uiColor: .secondarySystemBackground)}
        .onAppear {
            viewModel.onAppear()
        }
    }
}

#if DEBUG

private class DashboardViewModelMock: DashboardViewModelProtocol {
    var disappearCalled: Bool = false
    
    func onAppear() {

    }

    func onDisappear() {
        
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModelMock())
}

#endif
