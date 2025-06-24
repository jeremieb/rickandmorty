//
//  EpisodesViewModel.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import SwiftUI
import SwiftData

class EpisodesViewModel: ObservableObject {
    
    private var modelContext: ModelContext?
    
    /// Listing all episodes
    @Published var data: EpisodesResponse?
    /// Combined episodes from both API and local storage
    @Published var episodes: [Episode] = []
    /// Total episodes count for pagination
    @Published var totalEpisodesCount: Int = 0
    private var savedEpisodes: [Episode] = []
    
    /// Loading status for updating the display
    @Published var status: LoadingState<Void> = .idle
    /// Separate loading state for next page to avoid scroll jumping
    @Published var isLoadingNextPage: Bool = false
    /// Calling the network service
    private let networkService = NetworkService.shared
    /// Local storage | UserDefault keys
    private let lastFetchKey = "lastEpisodesFetchDate"
    private let totalEpisodesCountKey = "totalEpisodesCount"
    private let maxCacheAge: TimeInterval = 7 * 24 * 60 * 60 // 7 days in seconds
    
    /// Set the model context from the view
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadSavedEpisodes()
        
        /// Load the saved total count
        /// Used when coming back after killing the app
        /// because we don't have the info with the next page URL.
        totalEpisodesCount = UserDefaults.standard.integer(forKey: totalEpisodesCountKey)
        
        Task {
            await self.loadEpisodes()
        }
    }
    
    /// Load saved episodes from SwiftData
    private func loadSavedEpisodes() {
        guard let modelContext = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<Episode>(sortBy: [SortDescriptor(\.id)])
            savedEpisodes = try modelContext.fetch(descriptor)
        } catch {
            print("🔴 Failed to load saved episodes: \(error)")
            savedEpisodes = []
        }
    }
    
    /// Main Loading Function
    @MainActor
    func loadEpisodes(forceRefresh: Bool = false) async {
        guard modelContext != nil else {
            print("🔴 No model context available")
            return
        }
        
        /// If force refresh, clear all data and fetch from API
        if forceRefresh {
            print("🔶 Force refresh requested - clearing cache")
            clearPersistedEpisodes()
            loadSavedEpisodes()
        } else {
            clearDataIfNeeded()
            loadSavedEpisodes()
        }
        
        /// Use saved episodes only if not force refreshing and data is not expired
        if !forceRefresh && !savedEpisodes.isEmpty && !isDataExpired() {
            print("📺 Using \(savedEpisodes.count) saved episodes (not expired)")
            self.episodes = savedEpisodes
            self.status = .loaded(())
            return
        }
        
        print("📺 Fetching episodes from API (force refresh: \(forceRefresh))")
        
        do {
            self.status = .loading
            let response = try await networkService.fetchEpisodes()
            self.data = response
            
            /// Save total count to UserDefaults
            UserDefaults.standard.set(response.info.count, forKey: totalEpisodesCountKey)
            
            if let modelContext = modelContext {
                for episode in response.results {
                    modelContext.insert(episode)
                }
                try modelContext.save()
                print("📺 Saved \(response.results.count) episodes to SwiftData")
            }
            
            self.episodes = response.results
            
            UserDefaults.standard.set(Date.now, forKey: lastFetchKey)
            
            self.status = .loaded(())
        } catch {
            if !savedEpisodes.isEmpty {
                print("🔴 API failed, using \(savedEpisodes.count) saved episodes")
                self.episodes = savedEpisodes
                self.status = .loaded(())
            } else {
                self.status = .failed(error)
            }
            print("🔴 Error fetching episodes: \(error.localizedDescription)")
        }
    }
    
    /// Check if data is expired (older than 7 days)
    private func isDataExpired() -> Bool {
        guard let lastFetchDate = UserDefaults.standard.object(forKey: lastFetchKey) as? Date else {
            print("🔶 No last fetch date found - data considered expired")
            return true
        }
        
        let timeSinceLastFetch = Date().timeIntervalSince(lastFetchDate)
        let isExpired = timeSinceLastFetch > maxCacheAge
        print("💾 Data age: \(timeSinceLastFetch) seconds, expired: \(isExpired)")
        return isExpired
    }
    
    /// Clear SwiftData storage if data is older than 7 days
    private func clearDataIfNeeded() {
        if isDataExpired() {
            clearPersistedEpisodes()
            print("🔴 Cleared old episode data (older than 7 days)")
        }
    }
    
    /// Clear all persisted episodes from SwiftData
    private func clearPersistedEpisodes() {
        guard let modelContext = modelContext else { return }
        
        do {
            try modelContext.delete(model: Episode.self)
            try modelContext.save()
            savedEpisodes = []
            print("📺 Cleared all persisted episodes")
        } catch {
            print("🔴 Failed to clear persisted episodes: \(error)")
        }
    }
    
    /// Loading the next page
    @MainActor
    func loadNextPage() async {
        let currentEpisodeCount = episodes.count
        let totalEpisodesCount = UserDefaults.standard.integer(forKey: totalEpisodesCountKey)
        
        if currentEpisodeCount >= totalEpisodesCount {
            print("📺 All episodes already loaded (\(currentEpisodeCount)/\(totalEpisodesCount))")
            return
        }
        
        let nextPage = (currentEpisodeCount / 20) + 1
        
        print("📺 Loading page \(nextPage) (current episodes: \(currentEpisodeCount), total: \(totalEpisodesCount))")
        
        do {
            self.isLoadingNextPage = true
            let response = try await networkService.fetchEpisodes(page: nextPage)
            self.data = response
            
            if let modelContext = modelContext {
                for episode in response.results {
                    modelContext.insert(episode)
                }
                try modelContext.save()
            }
            
            self.episodes.append(contentsOf: response.results)
            print("📺 Added \(response.results.count) episodes from page \(nextPage)")
            self.isLoadingNextPage = false
        } catch {
            self.isLoadingNextPage = false
            print("🔴 Error fetching page \(nextPage): \(error.localizedDescription)")
        }
    }
}
