//
//  DashboardView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 18/10/2026.
//

import SwiftUI

struct DashboardView<ViewModel>: View where ViewModel: DashboardViewModelProtocol {

    enum C {
        static var chartHeight: CGFloat { 200 }
        static var spacing: CGFloat { 16 }
        static var emptySkeletonOpacity: Double { 0.4 }
        static var emptyShadowOpacity: Double { 0.12 }
        static var emptyShadowRadius: CGFloat { 24 }
        static var emptyShadowOffset: CGFloat { 8 }
    }

    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        ScrollView {
            switch viewModel.state {
            case .content(let contentViewData):
                content(contentViewData)
            default:
                skeleton
            }
        }
        .scrollDisabled(!viewModel.state.isContent)
        .overlay {
            if viewModel.state == .empty {
                emptyState
            }
        }
        .background {
            Self.background
                .ignoresSafeArea()
        }
        .navigationTitle("Dashboard".localized)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    viewModel.onAddGameTapped()
                } label: {
                    Label("Add game".localized, systemImage: "plus")
                }
            }
        }
        .animation(.default, value: viewModel.state)
        .task {
            await viewModel.onAppear()
        }
    }

    var skeleton: some View {
        content(.placeholder)
            .redacted(reason: .placeholder)
            .opacity(viewModel.state == .empty ? C.emptySkeletonOpacity : 1)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
    }

    var emptyState: some View {
        ContentUnavailableView {
            Label {
                Text("No games played yet".localized)
            } icon: {
                Image(systemName: "dice")
            }
        } description: {
            Text("Add your first game".localized)
        } actions: {
            Button {
                viewModel.onAddGameTapped()
            } label: {
                Label {
                    Text("Add game".localized)
                } icon: {
                    Image(systemName: "plus")
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .fixedSize(horizontal: false, vertical: true)
        .dashboardCard()
        .compositingGroup()
        .shadow(
            color: .black.opacity(C.emptyShadowOpacity),
            radius: C.emptyShadowRadius,
            y: C.emptyShadowOffset
        )
        .padding(.horizontal)
    }

    static var background: Color {
        Color(uiColor: .systemGroupedBackground)
    }

    func content(_ contentViewData: DashboardViewModelState.ContentData) -> some View {
        VStack(spacing: C.spacing) {
            ChartView()
                .frame(height: C.chartHeight)
                .frame(maxWidth: .infinity)
                .dashboardCard()
            LastGamesView(viewData: contentViewData.gamesViewData)
            TopWinnersView(viewData: contentViewData.winnersViewData)
        }
        .padding(.horizontal)
    }
}

#if DEBUG

#Preview("Content") {
    NavigationStack {
        DashboardView(viewModel: DashboardViewModelMock())
    }
}

#Preview("Loading") {
    NavigationStack {
        DashboardView(viewModel: DashboardViewModelMock(state: .loading))
    }
}

#Preview("Empty") {
    NavigationStack {
        DashboardView(viewModel: DashboardViewModelMock(state: .empty))
    }
}

#endif
