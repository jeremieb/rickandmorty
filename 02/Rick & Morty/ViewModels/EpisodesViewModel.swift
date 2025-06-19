//
//  EpisodesViewModel.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI

class EpisodesViewModel: ObservableObject {
    
    /// Listing all episodes
    @Published var data: EpisodesResponse?
    /// Appending existing Episodes with the next page
    @Published var episodes: [Episode] = []
    /// Loading status for updating the display
    @Published var status: LoadingState<Void> = .idle
    /// Calling the network service
    private let networkService = NetworkService.shared
    
    init() {
        Task {
            await self.loadEpisodes()
        }
    }
    
    /// Main Loading Function
    @MainActor
    func loadEpisodes() async {
        do {
            self.status = .loading
            let response = try await networkService.fetchEpisodes()
            self.data = response
            self.episodes = response.results
            self.status = .loaded(())
        } catch {
            self.status = .failed(error)
            print("Error fetching episodes: \(error.localizedDescription)")
        }
    }
    
    /// Loading the next page
    @MainActor
    func loadNextPage() async {
        guard let nextURL = data?.info.next,
              let urlComponents = URLComponents(url: nextURL, resolvingAgainstBaseURL: true),
              let pageQueryItem = urlComponents.queryItems?.first(where: { $0.name == "page" }),
              let pageString = pageQueryItem.value,
              let nextPage = Int(pageString) else {
            print("No next page available or could not parse next page URL.")
            return
        }
        
        do {
            self.status = .loading
            let response = try await networkService.fetchEpisodes(page: nextPage)
            self.data = response
            self.episodes.append(contentsOf: response.results)
            print("added \(response.results.count) episodes")
            self.status = .loaded(())
        } catch {
            self.status = .failed(error)
            print("Error fetching next page of episodes: \(error.localizedDescription)")
        }
    }
}
