//
//  ContentView.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 17/06/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        EpisodesListView()
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Episode.self)
}
