//
//  EpisodeRow.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct EpisodeRow: View {
    
    let episode: Episode
    
    var body: some View {
        HStack(spacing: 16) {
            if let episodeNumber = episode.episodeNumber {
                Image(systemName: "\(episodeNumber).circle.fill")
                    .resizable().scaledToFit()
                    .frame(width: 46)
                    .foregroundColor(.accent).opacity(0.5)
            }
            VStack(alignment: .leading, spacing: 8) {
                if let episodeName = episode.name {
                    Text(episodeName)
                        .font(.headline).fontWidth(.expanded)
                        .lineLimit(2)
                }
                EpisodeNumber(number: episode.episode)
                if let formattedAirDate = episode.formattedAirDate {
                    Text(formattedAirDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundStyle(Color.accentColor.opacity(0.5))
        }.padding(.vertical, 2)
    }
}
