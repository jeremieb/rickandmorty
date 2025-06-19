//___FILEHEADER___

import SwiftUI

@main
struct MainView: App {
    
    private var episodeVM = EpisodesViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(episodeVM)
        }
    }
}
