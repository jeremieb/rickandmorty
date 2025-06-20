//
//  CharactersViewModel.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation

class CharactersViewModel: ObservableObject {
    
    @Published var selectedCharacter: Character?
    
    @Published var status: LoadingState<Void> = .idle
    
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
}
