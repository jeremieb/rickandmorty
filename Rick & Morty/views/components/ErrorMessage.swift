//
//  ErrorMessage.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 20/06/2025.
//

import SwiftUI

struct ErrorMessage: View {
    @EnvironmentObject private var episodeVM: EpisodesViewModel
    
    var title: String?
    var description: String?
    
    var body: some View {
        ContentUnavailableView {
            Label(title ?? "No episode available", systemImage: "exclamationmark.triangle")
        } description: {
            Text(description ?? "Something went wrong")
        } actions: {
            Button("Try Again") {
                Task {
                    await episodeVM.loadEpisodes()
                }
            }.buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    ErrorMessage()
}
