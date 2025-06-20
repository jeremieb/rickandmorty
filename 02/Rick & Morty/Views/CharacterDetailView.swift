//
//  CharacterDetailView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct CharacterDetailView: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @EnvironmentObject private var characterVM: CharactersViewModel
    
    var selectedCharacterID: Int?
    
    var body: some View {
        if let selectedCharacterID {
            NavigationStack {
                Group {
                    switch characterVM.status {
                        case .idle:
                            ErrorMessage(description: "No character selected")
                        case .loading:
                            ProgressView()
                        case .loaded():
                            if let character = characterVM.selectedCharacter {
                                List {
                                    Section {
                                        VStack {
                                            if let imageURL = character.image {
                                                AsyncImage(url: URL(string: imageURL)) { image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .frame(width: 200, height: 200)
                                                .clipShape(Circle())
                                            }
                                        }.frame(maxWidth: .infinity, alignment: .center)
                                    }
                                    .listRowBackground(Color.clear)
                                    
                                    Section {
                                        switch character.formattedStatus {
                                            case .alive:
                                                CharacterDetailRow(label: "Status", value: "👍🏼 Alive")
                                            case .dead:
                                                CharacterDetailRow(label: "Status", value: "☠️ Dead")
                                            case .unknown:
                                                CharacterDetailRow(label: "Status", value: "🤨 Unknown")
                                        }
                                        if let species = character.species {
                                            CharacterDetailRow(label: "Species", value: species)
                                        }
                                        if let type = character.type {
                                            CharacterDetailRow(label: "Type", value: !type.isEmpty ? type : "-")
                                            /// Some characters have empty strings...
                                        }
                                        switch character.formattedGender {
                                            case .female:
                                                CharacterDetailRow(label: "Gender", value: "♀ Female")
                                            case .male:
                                                CharacterDetailRow(label: "Gender", value: "♂ Male")
                                            case .genderless:
                                                CharacterDetailRow(label: "Gender", value: "⚤ Genderless")
                                            case .unknown:
                                                CharacterDetailRow(label: "Gender", value: "Unknown")
                                        }
                                        if let originName = character.origin?.name {
                                            CharacterDetailRow(label: "Origin", value: originName)
                                        }
                                        if let episodesCount = character.episode?.count {
                                            CharacterDetailRow(label: "Appearance", value: "\(episodesCount) \(episodesCount <= 1 ? "episode" : "episodes")")
                                        }
                                    }
                                    
                                    Section {
                                        Button(action: {
                                            
                                        }){
                                            Label("Save this character", systemImage: "square.and.arrow.down")
                                                .fontWeight(.semibold).foregroundStyle(.primary)
                                                .frame(maxWidth: .infinity, alignment: .center)
                                        }.buttonStyle(.borderedProminent)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowInsets(.init())
                                }.navigationTitle(character.name ?? "No name")
                            } else {
                                ErrorMessage(description: "Error loading this character.")
                            }
                        case .failed(let error):
                            ErrorMessage(title: "No Character", description: error?.localizedDescription ?? "Error loading this character.")
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            dismiss()
                        }){
                            Image(systemName: "xmark.circle.fill")
                        }
                    }
                }
            }
            .task {
                Task {
                    await self.characterVM.loadCharacter(id: selectedCharacterID)
                }
            }
        } else {
            ErrorMessage(description: "No character selected")
        }
    }
}

#Preview {
    CharacterDetailView(selectedCharacterID: 1)
        .environmentObject(CharactersViewModel())
}
