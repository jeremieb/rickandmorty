//
//  EpisodesListView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI
import SwiftData

struct EpisodesListView: View {
    
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var episodeVM: EpisodesViewModel
    
    /// Selected Episode
    @State private var selectedEpisode: Episode?
    
    var body: some View {
        NavigationStack {
            Group {
                switch episodeVM.status {
                    case .idle:
                        ErrorMessage()
                    case .loading:
                        ProgressView()
                    case .loaded():
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
                            
                            /// if we have a info.next object, there is a second page
                            EndOfTheList()
                        }
                        .listStyle(.plain)
                        .refreshable {
                            Task {
                                await self.episodeVM.loadEpisodes(forceRefresh: true)
                            }
                        }
                        .navigationDestination(item: $selectedEpisode) { episode in
                            EpisodeDetailView(selectedEpisode: episode)
                        }
                    case .failed(let error):
                        ErrorMessage(description: error?.localizedDescription ?? "Something went wrong.")
                }
            }.navigationTitle("Rick & Morty")
        }
        .onAppear {
            self.episodeVM.setModelContext(modelContext)
        }
    }
    
    // MARK: Grouping episodes per season
    private var groupedEpisodes: [Int: [Episode]] {
        Dictionary(grouping: episodeVM.episodes) { episode in
            episode.seasonNumber ?? 0
        }
    }
    
    // MARK: End of the list
    @ViewBuilder private func EndOfTheList() -> some View {
        Section {
            VStack {
                if hasMoreEpisodes {
                    /// Avoid the full page refresh -> ScrollView position is lost 😩
                    if episodeVM.isLoadingNextPage {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Button(action: {
                            Task {
                                await self.episodeVM.loadNextPage()
                            }
                        }){
                            Text("more episodes")
                                .fontWeight(.semibold).font(.footnote)
                        }.buttonStyle(.borderedProminent)
                    }
                } else {
                    Text("End of the list")
                        .font(.footnote).foregroundStyle(.secondary)
                }
            }.frame(maxWidth: .infinity, alignment: .center)
        }
        .listRowBackground(Color.clear)
        .listRowInsets(.init())
        .listRowSeparator(.hidden)
        .padding()
    }
    
    // MARK: Do we have all the episodes?
    private var hasMoreEpisodes: Bool {
        let currentCount = episodeVM.episodes.count
        let totalCount = episodeVM.totalEpisodesCount
        return currentCount < totalCount && totalCount > 0
    }
}

#Preview {
    EpisodesListView()
}
