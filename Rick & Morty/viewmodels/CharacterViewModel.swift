//
//  CharacterViewModel.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation
import SwiftData

/// CharacterViewModel
///
/// This ViewModel manages character data fetching and caching.
/// It handles loading individual characters from the API and provides local caching using SwiftData.
///
/// Key Responsibilities:
/// - Fetch characters from the Rick & Morty API by ID
/// - Cache characters locally using SwiftData for offline access
/// - Manage loading states
/// - Implement smart refresh logic (only refresh after 7 days)
@MainActor
class CharacterViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Dictionary of characters keyed by their ID for quick access
    @Published var characters: [Int: Character] = [:]
    
    /// Set of character IDs currently being loaded
    @Published var loadingCharacterIDs: Set<Int> = []
    
    /// Error message to display to the user when something goes wrong
    @Published var errorMessage: String?
    
    // MARK: - Dependencies
    
    /// SwiftData context for saving/loading characters locally
    var modelContext: ModelContext
    
    /// Network service for making API calls (singleton pattern)
    private let networkService = NetworkService.shared
    
    /// UserDefaults for storing simple app preferences
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Configuration Constants
    
    /// How long to wait before refreshing from API again (7 days in seconds)
    private let refreshInterval: TimeInterval = 7 * 24 * 60 * 60
    
    // MARK: - Initialization
    
    /// Initialize the ViewModel with a SwiftData context
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadLocalCharacters()
    }
    
    // MARK: - Public Methods
    
    /// Load a character by ID
    func loadCharacter(id: Int) async {
        // Check if character is already loaded and fresh
        if let _ = characters[id], !shouldRefreshCharacter(id: id) {
            return
        }
        
        // Check if already loading
        if loadingCharacterIDs.contains(id) {
            return
        }
        
        loadingCharacterIDs.insert(id)
        errorMessage = nil
        
        do {
            let apiCharacter = try await networkService.fetchCharacter(id: id)
            let character = Character(from: apiCharacter)
            
            // Save to database
            if let existingCharacter = try? findLocalCharacter(id: id) {
                modelContext.delete(existingCharacter)
            }
            modelContext.insert(character)
            try modelContext.save()
            
            // Update UI
            characters[id] = character
            
            // Save fetch timestamp
            userDefaults.set(Date(), forKey: characterFetchDateKey(id: id))
            
        } catch {
            print("Failed to fetch character \(id): \(error)")
            errorMessage = error.localizedDescription
            
            // Try loading from cache if API fails
            if let localCharacter = try? findLocalCharacter(id: id) {
                characters[id] = localCharacter
            }
        }
        
        loadingCharacterIDs.remove(id)
    }
    
    /// Load multiple characters by IDs
    func loadCharacters(ids: [Int]) async {
        // Filter out characters that are already loaded and fresh
        let idsToFetch = ids.filter { id in
            guard characters[id] != nil else { return true }
            return shouldRefreshCharacter(id: id)
        }.filter { !loadingCharacterIDs.contains($0) }
        
        if idsToFetch.isEmpty { return }
        
        // Add to loading set
        for id in idsToFetch {
            loadingCharacterIDs.insert(id)
        }
        
        errorMessage = nil
        
        do {
            let apiCharacters = try await networkService.fetchCharacters(ids: idsToFetch)
            
            for apiCharacter in apiCharacters {
                let character = Character(from: apiCharacter)
                
                // Save to database
                if let existingCharacter = try? findLocalCharacter(id: character.id) {
                    modelContext.delete(existingCharacter)
                }
                modelContext.insert(character)
                
                // Update UI
                characters[character.id] = character
                
                // Save fetch timestamp
                userDefaults.set(Date(), forKey: characterFetchDateKey(id: character.id))
            }
            
            try modelContext.save()
            
        } catch {
            print("Failed to fetch characters \(idsToFetch): \(error)")
            errorMessage = error.localizedDescription
            
            // Try loading from cache if API fails
            for id in idsToFetch {
                if let localCharacter = try? findLocalCharacter(id: id) {
                    characters[id] = localCharacter
                }
            }
        }
        
        // Remove from loading set
        for id in idsToFetch {
            loadingCharacterIDs.remove(id)
        }
    }
    
    /// Get a character by ID (returns nil if not loaded)
    func character(id: Int) -> Character? {
        return characters[id]
    }
    
    /// Check if a character is currently loading
    func isLoading(id: Int) -> Bool {
        return loadingCharacterIDs.contains(id)
    }
    
    // MARK: - Private Methods
    
    /// Load all characters from local SwiftData database
    private func loadLocalCharacters() {
        do {
            let descriptor = FetchDescriptor<Character>()
            let localCharacters = try modelContext.fetch(descriptor)
            
            for character in localCharacters {
                characters[character.id] = character
            }
        } catch {
            print("Failed to load local characters: \(error)")
        }
    }
    
    /// Find a character in local database by ID
    private func findLocalCharacter(id: Int) throws -> Character? {
        let descriptor = FetchDescriptor<Character>(
            predicate: #Predicate<Character> { $0.id == id }
        )
        return try modelContext.fetch(descriptor).first
    }
    
    /// Check if we should refresh a character from API based on time elapsed
    private func shouldRefreshCharacter(id: Int) -> Bool {
        guard let lastFetchDate = userDefaults.object(forKey: characterFetchDateKey(id: id)) as? Date else {
            return true
        }
        
        let timeElapsed = Date().timeIntervalSince(lastFetchDate)
        return timeElapsed >= refreshInterval
    }
    
    /// Generate UserDefaults key for character fetch date
    private func characterFetchDateKey(id: Int) -> String {
        return "lastCharacterFetchDate_\(id)"
    }
}
