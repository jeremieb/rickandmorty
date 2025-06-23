import SwiftUI
import SwiftData

@main
struct MainView: App {
    
    private var episodeVM = EpisodesViewModel()
    private var characterVM = CharactersViewModel()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Episode.self, Character.self])
                .environmentObject(episodeVM)
                .environmentObject(characterVM)
        }
    }
}
