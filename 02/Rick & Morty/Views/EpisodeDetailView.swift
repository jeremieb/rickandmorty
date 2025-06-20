//
//  EpisodeDetailView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct EpisodeDetailView: View {
    
    var episode: Episode?
    
    var body: some View {
        if let episode {
            Text(episode.name ?? "")
        }
    }
}

#Preview {
    EpisodeDetailView()
}
