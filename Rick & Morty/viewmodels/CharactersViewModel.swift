//
//  CharactersViewModel.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation
import SwiftUI
import SwiftData

class CharactersViewModel: ObservableObject {
    
    private var modelContext: ModelContext?
    
    @Published var selectedCharacter: Character?
    @Published var status: LoadingState<Void> = .idle
    
    @Published var showingExporter = false
    @Published var exportFileName = "character.txt"
    @Published var exportDocument = TextDocument()
    
    private let networkService = NetworkService.shared
    
    /// Local storage | UserDefault keys
    private let lastCharacterFetchKey = "lastCharacterFetchDate_"
    private let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days in seconds
    
    /// Set the model context from the view
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    /// Load a specific character by ID with persistence (only when user selects)
    @MainActor
    func loadCharacter(id: Int) async {
        guard let modelContext = modelContext else {
            print("🔴 No model context available")
            return
        }
        
        status = .loading
        
        /// We try to load from local storage first
        if let savedCharacter = loadSavedCharacter(id: id, context: modelContext) {
            if !isCharacterDataExpired(id: id) {
                print("👽 Using saved character \(id) (not expired)")
                selectedCharacter = savedCharacter
                status = .loaded(())
                return
            }
        }

        print("👽 Fetching character \(id) from API")
        
        do {
            let character = try await networkService.fetchCharacter(id: id)
            
            /// Saving to SwiftData
            saveCharacterToStorage(character: character, context: modelContext)
            
            /// When the last loading was?
            UserDefaults.standard.set(Date.now, forKey: lastCharacterFetchKey + "\(id)")
            
            selectedCharacter = character
            status = .loaded(())
        } catch {
            /// If API fails, try to use saved data (even if expired)
            if let savedCharacter = loadSavedCharacter(id: id, context: modelContext) {
                print("🔴 API failed, using saved character \(id)")
                selectedCharacter = savedCharacter
                status = .loaded(())
            } else {
                status = .failed(error)
                selectedCharacter = nil
            }
            print("🔴 Error fetching character \(id): \(error.localizedDescription)")
        }
    }
    
    /// Reset all persisted character data (called during pull-to-refresh)
    func resetPersistedCharacterData() {
        guard let modelContext = modelContext else {
            print("No model context available for character reset")
            return
        }
        
        do {
            /// Delete all characters from SwiftData
            try modelContext.delete(model: Character.self)
            try modelContext.save()

            print("👽 Reset all persisted character data")
        } catch {
            print("🔴 Failed to reset persisted character data: \(error)")
        }
    }
    
    /// Load saved character from SwiftData
    private func loadSavedCharacter(id: Int, context: ModelContext) -> Character? {
        do {
            let descriptor = FetchDescriptor<Character>(
                predicate: #Predicate<Character> { character in
                    character.id == id
                }
            )
            let savedCharacters = try context.fetch(descriptor)
            return savedCharacters.first
        } catch {
            print("🔴 Failed to load saved character \(id): \(error)")
            return nil
        }
    }
    
    /// Save character to SwiftData storage
    private func saveCharacterToStorage(character: Character, context: ModelContext) {
        // First, check if character already exists and remove it
        if let existingCharacter = loadSavedCharacter(id: character.id, context: context) {
            context.delete(existingCharacter)
        }
        
        // Insert the new character
        context.insert(character)
        
        do {
            try context.save()
            print("👽 Saved character \(character.id) to SwiftData")
        } catch {
            print("🔴 Failed to save character \(character.id): \(error)")
        }
    }
    
    /// Check if character data is expired (older than 7 days)
    private func isCharacterDataExpired(id: Int) -> Bool {
        guard let lastFetchDate = UserDefaults.standard.object(forKey: lastCharacterFetchKey + "\(id)") as? Date else {
            print("🔴 No last fetch date found for character \(id) - data considered expired")
            return true
        }
        
        let timeSinceLastFetch = Date().timeIntervalSince(lastFetchDate)
        let isExpired = timeSinceLastFetch > maxCacheAge
        print("💾 Character \(id) data age: \(timeSinceLastFetch) seconds, expired: \(isExpired)")
        return isExpired
    }
    
    /// Clear the selected character
    func clearSelectedCharacter() {
        selectedCharacter = nil
        status = .idle
    }
    
    /// Export character as text file
    func exportCharacter() {
        guard let character = selectedCharacter else { return }
        
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
