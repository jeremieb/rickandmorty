//___FILEHEADER___

import SwiftUI

@main
struct MainView: App {
    
    private var episodeVM = EpisodesViewModel()
    private var characterVM = CharactersViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(episodeVM)
                .environmentObject(characterVM)
        }
    }
}
