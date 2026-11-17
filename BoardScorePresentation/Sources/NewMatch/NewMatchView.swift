//
//  NewMatchView.swift
//  BoardScorePresentation
//
//  Created by José María Jiménez on 12/11/2026.
//

import SwiftUI
import BoardScoreDomain

struct NewMatchView<ViewModel>: View where ViewModel: NewMatchViewModelProtocol {

    enum C {
        static var durationRange: ClosedRange<Int> { 5...600 }
        static var durationStep: Int { 5 }
    }

    @State private var isAddingPlayer = false
    @State private var newPlayerName = ""
    @State private var viewModel: ViewModel

    init(viewModel: ViewModel) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        NavigationStack {
            Form {
                gameSection
                dateSection
                if let game = viewModel.selectedGame {
                    scoresSection(game)
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .navigationTitle("New match".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbar }
            .confirmationDialog(
                "Change game?".localized,
                isPresented: isConfirmingGameChange,
                titleVisibility: .visible,
                presenting: viewModel.pendingGame
            ) { game in
                Button("Change".localized, role: .destructive) {
                    viewModel.confirmGameChange(game)
                }
                Button("Cancel".localized, role: .cancel) {
                    viewModel.cancelGameChange()
                }
            } message: { _ in
                Text("The scores entered will be deleted.".localized)
            }
            .confirmationDialog(
                "It's a tie".localized,
                isPresented: isResolvingTie,
                titleVisibility: .visible,
                presenting: viewModel.tiedPlayers
            ) { players in
                ForEach(players) { player in
                    Button(player.name) {
                        viewModel.selectTieWinner(player)
                    }
                }
                Button("Cancel".localized, role: .cancel) {
                    viewModel.cancelTie()
                }
            } message: { _ in
                Text("Choose the winner".localized)
            }
            .alert("New player".localized, isPresented: $isAddingPlayer) {
                TextField("Name".localized, text: $newPlayerName)
                    .textInputAutocapitalization(.words)
                Button("Add".localized) {
                    viewModel.addNewPlayer(name: newPlayerName)
                    newPlayerName = ""
                }
                Button("Cancel".localized, role: .cancel) {
                    newPlayerName = ""
                }
            }
            .alert("Couldn't save the player".localized, isPresented: $viewModel.showsAddPlayerError) {
                Button("OK".localized, role: .cancel) {}
            } message: {
                Text("Please try again.".localized)
            }
            .task {
                await viewModel.onAppear()
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

    var gameSection: some View {
        Section {
            Menu {
                Picker(selection: gameSelection) {
                    ForEach(viewModel.games) { game in
                        Text(game.name)
                            .tag(Optional(game))
                    }
                } label: {
                    EmptyView()
                }
                .pickerStyle(.inline)
                Divider()
                Button {
                    viewModel.addNewGame()
                } label: {
                    Label("Add new game".localized, systemImage: "plus")
                }
            } label: {
                LabeledContent {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedGame?.name ?? "Choose".localized)
                        Image(systemName: "chevron.up.chevron.down")
                            .imageScale(.small)
                    }
                    .foregroundStyle(Color.secondary)
                } label: {
                    Text("Game".localized)
                        .foregroundStyle(Color.primary)
                }
            }
        }
    }

    var dateSection: some View {
        Section {
            DatePicker("Date".localized, selection: $viewModel.date)
            Toggle("Duration".localized, isOn: $viewModel.hasDuration)
            if let minutes = viewModel.durationMinutes {
                Stepper(value: durationBinding(minutes), in: C.durationRange, step: C.durationStep) {
                    Text(Duration.seconds(minutes * 60).formatted(.units(allowed: [.hours, .minutes], width: .wide)))
                        .monospacedDigit()
                }
            }
        }
    }

    var addPlayerMenu: some View {
        Menu {
            ForEach(viewModel.availablePlayers) { player in
                Button(player.name) {
                    viewModel.addExistingPlayer(player)
                }
            }
            if !viewModel.availablePlayers.isEmpty {
                Divider()
            }
            Button {
                isAddingPlayer = true
            } label: {
                Label("Create player".localized, systemImage: "person.badge.plus")
            }
        } label: {
            Label("Add player".localized, systemImage: "plus.circle.fill")
        }
    }

    func scoresSection(_ game: Domain.GameModel) -> some View {
        Section {
            if !viewModel.participants.isEmpty {
                NewMatchScoreGridView(viewModel: viewModel, game: game)
            }
            addPlayerMenu
        } header: {
            Text("Scores".localized)
        } footer: {
            if viewModel.participants.count < ViewModel.minimumPlayers {
                Text("At least 2 players are needed to save.".localized)
            }
        }
    }
}

private extension NewMatchView {
    var gameSelection: Binding<Domain.GameModel?> {
        Binding {
            viewModel.selectedGame
        } set: { game in
            guard let game else { return }

            viewModel.selectGame(game)
        }
    }

    var isConfirmingGameChange: Binding<Bool> {
        Binding {
            viewModel.pendingGame != nil
        } set: { isPresented in
            if !isPresented {
                viewModel.cancelGameChange()
            }
        }
    }

    var isResolvingTie: Binding<Bool> {
        Binding {
            !viewModel.tiedPlayers.isEmpty
        } set: { isPresented in
            if !isPresented {
                viewModel.cancelTie()
            }
        }
    }

    func durationBinding(_ minutes: Int) -> Binding<Int> {
        Binding {
            minutes
        } set: { newValue in
            viewModel.durationMinutes = newValue
        }
    }
}

#if DEBUG

#Preview("Content") {
    NewMatchView(viewModel: NewMatchViewModelMock())
}

#Preview("Empty") {
    NewMatchView(
        viewModel: NewMatchViewModelMock(
            selectedGame: nil,
            participants: [],
            availablePlayers: Domain.PlayerModel.previewPlayers,
            scores: [:],
            durationMinutes: nil
        )
    )
}

#endif
