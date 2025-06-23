//
//  EpisodeNumber.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

struct EpisodeNumber: View {
    var number: String?
    
    var body: some View {
        if let number {
            Text(number)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.accent.opacity(0.2))
                .cornerRadius(10)
        }
    }
}

#Preview {
    EpisodeNumber()
}
