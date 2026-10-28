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
        ScrollView {
            if case .content(let gamesViewData) = viewModel.state {
                content(gamesViewData)
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .background {
            Color(uiColor: .secondarySystemBackground)
                .ignoresSafeArea()
        }
        .onAppear {
            viewModel.onAppear()
        }
    }

    func content(_ contentViewData: DashboardViewModelState.ContentData) -> some View {
        VStack {
            ChartView()
                .padding(.horizontal, DashboardViewConstants.chartPadding)
            LastGamesView(viewData: contentViewData.gamesViewData)
            TopWinnersView(viewData: contentViewData.winnersViewData)
            Spacer()
        }
    }
}

#if DEBUG

private class DashboardViewModelMock: DashboardViewModelProtocol {
    let state: DashboardViewModelState = .idle

    func onAppear() {
        
    }
}

#Preview {
    DashboardView(viewModel: DashboardViewModelMock())
}

#endif
