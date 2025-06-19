//
//  CharacterDetailView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct CharacterDetailView: View {
    
    @Environment(\.dismiss) private var dismiss

    
    let characterID: Int?
    @ObservedObject var characterViewModel: CharacterViewModel
    
    private var character: Character? {
        guard let characterID = characterID else { return nil }
        return characterViewModel.character(id: characterID)
    }
    
    private var isLoading: Bool {
        guard let characterID = characterID else { return false }
        return characterViewModel.isLoading(id: characterID)
    }
    
    var body: some View {
        NavigationView {
            Group {
                if let character = character {
                    // Character is loaded - show details
                    ScrollView {
                        AsyncImage(url: URL(string: character.image)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 200, height: 200)
                        .clipShape(Circle())
                        
                        // Character details
                        VStack(alignment: .leading, spacing: 12) {
                            
                            Text("Status: \(character.status)")
                            
                            Text("Species: \(character.species)")
                            
                            Text("Type: \(character.type)")
                            
                            Text("Gender: \(character.gender)")
                            
                            Text("Origin: \(character.originName)")
                            
                            Text("Location: \(character.locationName)")
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    }
                    .navigationTitle(character.name)
                } else if isLoading {
                    // Character is loading - show loading indicator
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("Loading character...")
                            .font(.title2)
                    }
                } else {
                    // No character or error - show error state
                    ContentUnavailableView(
                        "No Character",
                        systemImage: "person.slash",
                        description: Text("Something went wrong when loading the character... 👽")
                    )
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {
                        dismiss()
                    }){
                        Image(systemName: "xmark.circle.fill")
                    }
                }
            }
            .onAppear {
                // Load character when view appears if not already loaded
                if let characterID = characterID, character == nil && !isLoading {
                    Task {
                        await characterViewModel.loadCharacter(id: characterID)
                    }
                }
            }
        }
    }
}
//
//#Preview {
//    // Create a mock character view model for preview
//    let mockViewModel = CharacterViewModel(modelContext: ModelContext(try! ModelContainer(for: Character.self)))
//    return CharacterDetailView(characterID: 1, characterViewModel: mockViewModel)
//}
