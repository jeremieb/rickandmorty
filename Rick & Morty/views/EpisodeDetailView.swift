//
//  EpisodeDetailView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct EpisodeDetailView: View {
    
    @Binding var selectedEpisode: Episode?
    
    var body: some View {
        if let selectedEpisode {
            ScrollView {
                EpisodeNumber(number: selectedEpisode.episode)
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
    EpisodeDetailView(selectedEpisode: .constant(nil))
}
