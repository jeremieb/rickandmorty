//
//  EpisodesListView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 17/06/2025.
//

import SwiftUI
import SwiftData

struct EpisodesListView: View {
    @StateObject private var viewModel: EpisodesViewModel
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedEpisode: Episode?
    
    init() {
        self._viewModel = StateObject(wrappedValue: EpisodesViewModel(modelContext: ModelContext(try! ModelContainer(for: Episode.self))))
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if viewModel.isLoading {
                    ProgressView("Loading episodes...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.episodes.isEmpty {
                    ScrollView {
                        ContentUnavailableView(
                            "No Episodes",
                            systemImage: "tv",
                            description: Text("Pull to refresh or check your internet connection")
                        )
                    }
                    .refreshable {
                        await viewModel.refreshEpisodes()
                    }
                } else {
                    List {
                        ForEach(groupedEpisodes.keys.sorted(), id: \.self) { seasonNumber in
                            Section(header: Text("Season \(seasonNumber)")) {
                                ForEach(groupedEpisodes[seasonNumber] ?? [], id: \.id) { episode in
                                    Button(action: {
                                        self.selectedEpisode = episode
                                    }){
                                        EpisodeRow(episode: episode)
                                    }
                                }
                            }
                        }
                        
                        /// Load more or not
                        EndList()
                    }
                    .refreshable {
                        await viewModel.refreshEpisodes()
                    }
                    .listStyle(.plain)
                    .navigationDestination(item: $selectedEpisode) { episode in
                        EpisodeDetailView(selectedEpisode: episode)
                    }
                }
                
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle("Rick & Morty")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.shouldShowRefreshHint {
                        Button("Refresh") {
                            Task {
                                await viewModel.refreshEpisodes()
                            }
                        }
                        .foregroundColor(.orange)
                    }
                }
            }
        }
        .task {
            await viewModel.loadEpisodes()
        }
        .onAppear {
            viewModel.modelContext = modelContext
        }
    }
    
    // MARK: End list
    @ViewBuilder
    private func EndList() -> some View {
        Section {
            if viewModel.hasMorePages {
                Button(action: {
                    Task {
                        await viewModel.loadNextPage()
                    }
                }) {
                    HStack {
                        if viewModel.isLoadingMore {
                            ProgressView().scaleEffect(0.8)
                            Text("Loading page \(viewModel.currentPage + 1)...")
                        } else {
                            Image(systemName: "arrow.down.circle.fill").font(.body)
                            Text("Next")
                        }
                    }
                    .font(.caption)
                    .foregroundColor(viewModel.isLoadingMore ? .secondary : .accentColor)
                    .frame(maxWidth: .infinity, alignment: .center)
                }.disabled(viewModel.isLoadingMore)
            } else if !viewModel.episodes.isEmpty {
                Text("Stay tuned for more episodes soon...")
                    .font(.caption).foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            }
        }
        .listRowInsets(.init())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    // MARK: Grouping episodes per season
    private var groupedEpisodes: [Int: [Episode]] {
        Dictionary(grouping: viewModel.episodes) { episode in
            episode.seasonNumber
        }
    }
}

#Preview {
    EpisodesListView()
}
