//
//  EpisodeRowView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 17/06/2025.
//

import SwiftUI

struct EpisodeRowView: View {
    let episode: Episode
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: "\(episode.episodeNumber).circle.fill")
                .resizable().scaledToFit()
                .frame(width: 46)
                .foregroundColor(.accent).opacity(0.5)
            VStack(alignment: .leading, spacing: 8) {
                Text(episode.name)
                    .font(.headline).fontWidth(.expanded)
                    .lineLimit(2)
                Text(episode.episode)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.accent.opacity(0.2))
                    .cornerRadius(10)
                Text(episode.airDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        
        .padding(.vertical, 2)
    }
}
