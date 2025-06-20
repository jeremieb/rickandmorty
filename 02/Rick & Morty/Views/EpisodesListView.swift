//
//  EpisodesListView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct EpisodesListView: View {
    
    @EnvironmentObject private var episodeVM: EpisodesViewModel
    
    /// Selected Episode
    @State private var selectedEpisode: Episode?
    
    var body: some View {
        NavigationStack {
            Group {
                switch episodeVM.status {
                    case .idle:
                        ContentUnavailableView {
                            Label("No episode available", systemImage: "exclamationmark.triangle")
                        } description: {
                            Text("Something went wrong.")
                        } actions: {
                            Button("Try Again") {
                                Task {
                                    await episodeVM.loadEpisodes()
                                }
                            }.buttonStyle(.borderedProminent)
                        }
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
                            Section {
                                VStack {
                                    if episodeVM.data?.info.next != nil {
                                        Button(action: {
                                            Task {
                                                await self.episodeVM.loadNextPage()
                                            }
                                        }){
                                            Text("more episodes")
                                        }.buttonStyle(.borderedProminent)
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
                        .listStyle(.plain)
                        .refreshable {
                            Task {
                                await self.episodeVM.loadEpisodes()
                            }
                        }
                        .navigationDestination(item: $selectedEpisode) { episode in
                            EpisodeDetailView(episode: episode)
                        }
                    case .failed(let error):
                        ContentUnavailableView {
                            Label("No episode available", systemImage: "exclamationmark.triangle")
                        } description: {
                            Text(error?.localizedDescription ?? "Something went wrong.")
                        } actions: {
                            Button("Try Again") {
                                Task {
                                    await episodeVM.loadEpisodes()
                                }
                            }.buttonStyle(.borderedProminent)
                        }
                }
            }.navigationTitle("Rick & Morty")
        }
    }
    
    // MARK: Grouping episodes per season
    private var groupedEpisodes: [Int: [Episode]] {
        Dictionary(grouping: episodeVM.episodes) { episode in
            episode.seasonNumber ?? 0
        }
    }
}

#Preview {
    EpisodesListView()
}
