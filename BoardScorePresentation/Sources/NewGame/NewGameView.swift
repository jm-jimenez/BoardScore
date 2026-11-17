//
//  NewGameView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 16/11/2026.
//

import SwiftUI
import BoardScoreDomain

struct NewGameView<ViewModel>: View where ViewModel: NewGameViewModelProtocol {

    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                nameSection
                winConditionSection
                scoreablesSection
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New game".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .alert("Couldn't save the game".localized, isPresented: $viewModel.showsSaveError) {
                Button("OK".localized, role: .cancel) {}
            } message: {
                Text("Please try again.".localized)
            }
            .task {
                await viewModel.onAppear()
            }
        }
    }
}

private extension NewGameView {
    var nameSection: some View {
        Section {
            TextField("Name".localized, text: $viewModel.name)
                .textInputAutocapitalization(.words)
        } footer: {
            if viewModel.isDuplicateName {
                Text("A game with this name already exists.".localized)
            }
        }
    }

    var winConditionSection: some View {
        Section("Winner".localized) {
            Picker("Winner".localized, selection: $viewModel.winCondition) {
                Text("Highest score".localized)
                    .tag(Domain.WinCondition.highestScore)
                Text("Lowest score".localized)
                    .tag(Domain.WinCondition.lowestScore)
            }
            .pickerStyle(.segmented)
            .labelsHidden()
        }
    }

    var scoreablesSection: some View {
        Section {
            ForEach(viewModel.scoreables) { scoreable in
                TextField("Scoreable name".localized, text: nameBinding(for: scoreable))
                    .textInputAutocapitalization(.sentences)
            }
            .onDelete { offsets in
                viewModel.removeScoreables(at: offsets)
            }
            .onMove { source, destination in
                viewModel.moveScoreables(from: source, to: destination)
            }
            Button {
                viewModel.addScoreable()
            } label: {
                Label("Add scoreable".localized, systemImage: "plus.circle.fill")
            }
        } header: {
            Text("Scoreables".localized)
        } footer: {
            if !viewModel.hasScoreables {
                Text("At least one scoreable is needed to save.".localized)
            } else if viewModel.hasEmptyScoreables {
                Text("Scoreables can't be empty.".localized)
            }
        }
    }

    @ToolbarContentBuilder
    var toolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel".localized) {
                viewModel.cancel()
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Save".localized) {
                viewModel.save()
            }
            .disabled(!viewModel.canSave)
        }
    }

    func nameBinding(for scoreable: Domain.ScoreableModel) -> Binding<String> {
        Binding {
            scoreable.name
        } set: { name in
            viewModel.renameScoreable(scoreable, to: name)
        }
    }
}

#if DEBUG

#Preview("Empty") {
    NewGameView(viewModel: NewGameViewModelMock())
}

#Preview("Filled") {
    NewGameView(
        viewModel: NewGameViewModelMock(
            name: "Wingspan",
            scoreables: Domain.GameModel.previewWingspan.scoreables
        )
    )
}

#Preview("Duplicate") {
    NewGameView(
        viewModel: NewGameViewModelMock(
            name: "Wingspan",
            scoreables: Domain.GameModel.previewWingspan.scoreables,
            isDuplicateName: true
        )
    )
}

#endif
