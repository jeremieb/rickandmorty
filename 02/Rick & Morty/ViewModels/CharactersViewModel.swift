//
//  CharactersViewModel.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation
import SwiftUI

class CharactersViewModel: ObservableObject {
    
    @Published var selectedCharacter: Character?
    
    @Published var status: LoadingState<Void> = .idle
    
    @Published var showingExporter = false
    @Published var exportFileName = "character.txt"
    @Published var exportDocument = TextDocument()

    private let networkService = NetworkService.shared
    
    /// Load a specific character by ID
    @MainActor
    func loadCharacter(id: Int) async {
        status = .loading
        
        do {
            let character = try await networkService.fetchCharacter(id: id)
            selectedCharacter = character
            status = .loaded(())
        } catch {
            status = .failed(error)
            selectedCharacter = nil
        }
    }
    
    /// Clear the selected character
    func clearSelectedCharacter() {
        selectedCharacter = nil
        status = .idle
    }
    
    /// Export character as text file
    func exportCharacter() {
        guard let character = selectedCharacter else { return }
        
        // -         exportText = formatCharacterAsText(character)
        let characterText = formatCharacterAsText(character)
        exportDocument = TextDocument(text: characterText)
        exportFileName = "\(character.name ?? "Character_\(character.id)").txt"
        showingExporter = true
    }
    
    /// Format character data as readable text
    private func formatCharacterAsText(_ character: Character) -> String {
        var text = "RICK & MORTY CHARACTER\n"
        text += "====================\n\n"
        
        text += "Name: \(character.name ?? "Unknown")\n"
        text += "Status: \(character.status ?? "Unknown")\n"
        text += "Species: \(character.species ?? "Unknown")\n"

        if let originName = character.origin?.name {
            text += "Origin: \(originName)\n"
        }

        if let episodes = character.episode {
            text += "Appears in \(episodes.count) \(episodes.count <= 1 ? "episode" : "episodes") \n"
        }

        return text
    }
}
