//
//  CharacterDetailView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct CharacterDetailView: View {
    
    var selectedCharacterID: Int?
    
    var body: some View {
        if let selectedCharacterID {
            Text("\(selectedCharacterID)")
        } else {
            ErrorMessage(description: "No character selected")
        }
    }
}

#Preview {
    CharacterDetailView()
}
