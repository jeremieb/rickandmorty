//___FILEHEADER___

import SwiftUI
import SwiftData

@main
struct MainView: App {
    var body: some Scene {
        WindowGroup {
            EpisodesListView()
        }
        .modelContainer(for: [Episode.self, Character.self])
    }
}
