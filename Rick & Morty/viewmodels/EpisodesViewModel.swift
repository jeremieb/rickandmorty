//
//  EpisodesViewModel.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 17/06/2025.
//

import Foundation
import SwiftData

/// EpisodesViewModel
///
/// This ViewModel acts as the bridge between the UI (EpisodesListView) and the data layer.
/// It manages the state of episodes, handles API calls, and provides local caching using SwiftData.
///
/// Key Responsibilities:
/// - Fetch episodes from the Rick & Morty API page by page
/// - Cache episodes locally using SwiftData for offline access
/// - Manage loading states and pagination
/// - Implement smart refresh logic (only refresh after 7 days)
@MainActor
class EpisodesViewModel: ObservableObject {
    
    // MARK: - Published Properties (Observable by UI)
    
    /// Array of episodes to display in the UI. This updates the UI automatically when changed.
    @Published var episodes: [Episode] = []
    
    /// Indicates if the initial load is in progress (shows main loading spinner)
    @Published var isLoading = false
    
    /// Indicates if loading more episodes is in progress (shows "loading more" indicator)
    @Published var isLoadingMore = false
    
    /// Error message to display to the user when something goes wrong
    @Published var errorMessage: String?
    
    /// Current page number we're on (starts at 1)
    @Published var currentPage = 1
    
    /// Total number of pages available from the API (Rick & Morty has 3 pages total)
    @Published var totalPages = 1
    
    /// Whether there are more pages available to load from the API
    @Published var hasMorePages = false
    
    // MARK: - Dependencies
    
    /// SwiftData context for saving/loading episodes locally
    var modelContext: ModelContext
    
    /// Network service for making API calls (singleton pattern)
    private let networkService = NetworkService.shared
    
    /// UserDefaults for storing simple app preferences
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Configuration Constants
    
    /// Key for storing the last time we fetched data from the API
    private let lastFetchDateKey = "lastEpisodesFetchDate"
    
    /// How long to wait before refreshing from API again (7 days in seconds)
    private let refreshInterval: TimeInterval = 7 * 24 * 60 * 60
    
    // MARK: - Initialization
    
    /// Initialize the ViewModel with a SwiftData context
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadLocalEpisodes()
    }
    
    // MARK: - Public Methods (Called by UI)
    
    /// Main method called when the view appears
    func loadEpisodes() async {
        if shouldRefreshFromAPI() {
            await refreshEpisodes()
        } else {
            loadLocalEpisodes()
            if episodes.isEmpty {
                await loadFirstPage()
            } else {
                hasMorePages = false // Local data loaded, no pagination needed
            }
        }
    }
    
    /// Force refresh episodes from the API
    func refreshEpisodes() async {
        isLoading = true
        errorMessage = nil
        
        // Reset pagination and clear local data
        currentPage = 1
        totalPages = 1
        hasMorePages = false
        try? deleteAllEpisodes()
        episodes.removeAll()
        
        await loadFirstPage()
    }
    
    /// Load the next page of episodes from the API
    func loadNextPage() async {
        guard hasMorePages && !isLoadingMore else { return }
        
        isLoadingMore = true
        errorMessage = nil
        
        await fetchPage(currentPage + 1)
    }
    
    // MARK: - Private Methods
    
    /// Check if we should refresh from API based on time elapsed
    private func shouldRefreshFromAPI() -> Bool {
        guard let lastFetchDate = userDefaults.object(forKey: lastFetchDateKey) as? Date else {
            return true
        }
        
        let timeElapsed = Date().timeIntervalSince(lastFetchDate)
        return timeElapsed >= refreshInterval
    }
    
    /// Load episodes from local SwiftData database
    private func loadLocalEpisodes() {
        do {
            let descriptor = FetchDescriptor<Episode>(sortBy: [SortDescriptor(\.id)])
            episodes = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to load local episodes: \(error)")
            errorMessage = "Failed to load episodes from local storage"
        }
    }
    
    /// Load the first page from API
    private func loadFirstPage() async {
        await fetchPage(1)
    }
    
    /// Fetch a specific page from the API
    private func fetchPage(_ page: Int) async {
        do {
            let response = try await networkService.fetchEpisodes(page: page)
            
            // Update pagination info
            currentPage = page
            totalPages = response.info.pages
            hasMorePages = response.info.next != nil
            
            // Convert and save episodes
            let newEpisodes = response.results.map { Episode(from: $0) }
            
            for episode in newEpisodes {
                modelContext.insert(episode)
            }
            try modelContext.save()
            
            // Update UI
            episodes.append(contentsOf: newEpisodes)
            
            // Save successful fetch timestamp
            userDefaults.set(Date(), forKey: lastFetchDateKey)
            
        } catch {
            print("Failed to fetch page \(page): \(error)")
            errorMessage = error.localizedDescription
            
            // If first page fails, try loading from cache
            if page == 1 {
                loadLocalEpisodes()
                hasMorePages = false
            }
        }
        
        isLoading = false
        isLoadingMore = false
    }
    
    /// Delete all episodes from local database
    private func deleteAllEpisodes() throws {
        let descriptor = FetchDescriptor<Episode>()
        let existingEpisodes = try modelContext.fetch(descriptor)
        
        for episode in existingEpisodes {
            modelContext.delete(episode)
        }
    }
    
    // MARK: - Computed Properties
    
    var lastFetchDate: Date? {
        return userDefaults.object(forKey: lastFetchDateKey) as? Date
    }
    
    var daysSinceLastFetch: Int? {
        guard let lastFetch = lastFetchDate else { return nil }
        let daysDifference = Calendar.current.dateComponents([.day], from: lastFetch, to: Date()).day
        return daysDifference
    }
    
    var shouldShowRefreshHint: Bool {
        guard let days = daysSinceLastFetch else { return false }
        return days >= 7
    }
}
