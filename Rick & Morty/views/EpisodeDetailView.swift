//
//  EpisodeDetailView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct EpisodeDetailView: View {
    
    var selectedEpisode: Episode?
    
    var body: some View {
        if let selectedEpisode {
            ScrollView {
                VStack(alignment: .leading) {
                    EpisodeNumber(number: selectedEpisode.episode)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationTitle(selectedEpisode.name)
        } else {
            ContentUnavailableView(
                "No Episodes",
                systemImage: "tv",
                description: Text("Something went wrong when selecting an episode... 🛸")
            )
        }
    }
}

#Preview {
    EpisodeDetailView(selectedEpisode: nil)
}
