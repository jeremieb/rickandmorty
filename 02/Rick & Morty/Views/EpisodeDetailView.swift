//
//  EpisodeDetailView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct EpisodeDetailView: View {
    
    var selectedEpisode: Episode?
    
    @State private var selectedCharacterID: Int?
    
    let columns = Array(repeating: GridItem(.fixed(64)), count: 5)
    
    var body: some View {
        if let selectedEpisode {
            if let characterIDs = selectedEpisode.characterIDs {
                ScrollView {
                    Text("Characters ID")
                        .font(.title2).fontWeight(.semibold)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(characterIDs, id: \.self) { characterID in
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
                            }.accentColor(Color.primary)
                        }
                    }
                    .sheet(item: $selectedCharacterID) { characterID in
                        CharacterDetailView(selectedCharacterID: characterID)
                    }
                }
                
            } else {
                ErrorMessage(description: "No character for this episode")
            }
        } else {
            ErrorMessage(description: "No episode selected")
        }
    }
}

#Preview {
    EpisodeDetailView()
}
