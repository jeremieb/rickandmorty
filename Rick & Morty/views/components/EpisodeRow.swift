//
//  EpisodeRow.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 17/06/2025.
//

import SwiftUI

struct EpisodeRow: View {
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
                EpisodeNumber(number: episode.episode)
                Text(episode.formattedAirDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.accentColor.opacity(0.5))
        }.padding(.vertical, 2)
    }
}
