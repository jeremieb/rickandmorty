//
//  EpisodeDetailView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI
import SwiftData

struct EpisodeDetailView: View {
    
    var selectedEpisode: Episode?
    
    let columns = Array(repeating: GridItem(.fixed(64)), count: 5)
    
    @State private var selectedCharacterID: Int?
    @State private var showingCharacterDetail = false
    @StateObject private var characterViewModel: CharacterViewModel
    @Environment(\.modelContext) private var modelContext
    
    init(selectedEpisode: Episode?) {
        self.selectedEpisode = selectedEpisode
        self._characterViewModel = StateObject(wrappedValue: CharacterViewModel(modelContext: ModelContext(try! ModelContainer(for: Character.self))))
    }
    
    var body: some View {
        if let selectedEpisode {
            ScrollView {
                Text("Characters ID")
                    .font(.title2).fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                LazyVGrid(columns: columns, spacing: 16) {
                    if let characterIDs = selectedEpisode.characterIDs {
                        ForEach(characterIDs, id: \.self) { characterID in
                            Button(action: {
                                self.selectedCharacterID = characterID
                                self.showingCharacterDetail = true
                                
                                // Load character if not already loaded
                                if characterViewModel.character(id: characterID) == nil {
                                    Task {
                                        await characterViewModel.loadCharacter(id: characterID)
                                    }
                                }
                            }){
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.6))
                                        .frame(width: 64, height: 64)
                                    
                                    if characterViewModel.isLoading(id: characterID) {
                                        ProgressView()
                                            .scaleEffect(0.8)
                                            .tint(.white)
                                    } else {
                                        Text("\(characterID)")
                                            .font(.headline).fontWeight(.bold).fontDesign(.rounded)
                                    }
                                }
                            }
                            .accentColor(Color.white).opacity(characterViewModel.isLoading(id: characterID) ? 0.6 : 1)
                            .disabled(characterViewModel.isLoading(id: characterID))
                        }
                    }
                }.padding()
                
                if let errorMessage = characterViewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                }
            }
            .navigationTitle(selectedEpisode.name ?? "No Episode Title")
            .onAppear {
                characterViewModel.modelContext = modelContext
                if let charactersIDs = selectedEpisode.characterIDs {
                    Task {
                        await characterViewModel.loadCharacters(ids: charactersIDs)
                    }
                }
            }
            .sheet(isPresented: $showingCharacterDetail) {
                CharacterDetailView(
                    characterID: selectedCharacterID,
                    characterViewModel: characterViewModel
                )
            }
            
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
