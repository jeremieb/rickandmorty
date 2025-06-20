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
                                await self.episodeVM.loadEpisodes()
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
                if episodeVM.data?.info.next != nil {
                    Button(action: {
                        Task {
                            await self.episodeVM.loadNextPage()
                        }
                    }){
                        Text("more episodes")
                            .fontWeight(.semibold).font(.footnote)
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
}

#Preview {
    EpisodesListView()
}
