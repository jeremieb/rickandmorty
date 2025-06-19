//
//  EpisodesListView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct EpisodesListView: View {
    
    @EnvironmentObject private var episodeVM: EpisodesViewModel
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedEpisodes.keys.sorted(), id: \.self) { seasonNumber in
                    Section(header: Text("Season \(seasonNumber)")) {
                        ForEach(groupedEpisodes[seasonNumber] ?? [], id: \.id) { episode in
                            Button(action: {
                                
                            }){
                                EpisodeRow(episode: episode)
                            }
                        }
                    }
                }
                
                /// if we have an URL, there is a second page
                Section {
                    if episodeVM.data?.info.next != nil {
                        Button(action: {
                            Task {
                                await self.episodeVM.loadNextPage()
                            }
                        }){
                            Text("Next page")
                        }
                    } else {
                        Text("End of the list")
                    }
                }
                .listRowBackground(Color.clear)
                .listRowInsets(.init())
            }
            .listStyle(.plain)
            .refreshable {
                Task {
                    await self.episodeVM.loadEpisodes()
                }
            }
            .navigationTitle("Rick & Morty")
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
