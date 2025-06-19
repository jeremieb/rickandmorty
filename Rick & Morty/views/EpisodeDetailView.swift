//
//  EpisodeDetailView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct EpisodeDetailView: View {
    
    var selectedEpisode: Episode?
    
    let columns = Array(repeating: GridItem(.fixed(64)), count: 5)
    
    @State private var selectedCharacterID: Int?
    
    var body: some View {
        if let selectedEpisode {
            ScrollView {
                Text("Characters ID")
                    .font(.title2).fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(selectedEpisode.characterIDs, id: \.self) { characterID in
                        Button(action: {
                            self.selectedCharacterID = characterID
                        }){
                            ZStack {
                                Circle()
                                    .fill(Color.orange.opacity(0.6))
                                    .frame(width: 64, height: 64)
                                Text("\(characterID)")
                                    .font(.headline).fontWeight(.bold).fontDesign(.rounded)
                            }
                        }.accentColor(Color.white)
                    }
                }.padding()
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
