//
//  NetworkService.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 17/06/2025.
//

import Foundation

/// NetworkService
///
/// Handles all network communication with the Rick & Morty API
/// Uses singleton pattern to ensure consistent network configuration across the app
///
/// Key Responsibilities:
/// - Fetch all episodes from the Rick & Morty API
/// - Handle network errors and provide meaningful error messages
/// - Manage API pagination internally (Rick & Morty has 3 pages of episodes)
class NetworkService {
    
    /// Shared instance of NetworkService (singleton pattern)
    static let shared = NetworkService()
    
    /// Base URL for the Rick & Morty API
    private let baseURL = "https://rickandmortyapi.com/api"
    
    /// Private initializer to enforce singleton pattern
    private init() {}
    
    /// Fetch a specific page of episodes from the Rick & Morty API
    ///
    /// - Parameter page: Page number to fetch (defaults to 1)
    /// - Returns: EpisodesResponse containing episodes and pagination info for that specific page
    /// - Throws: NetworkError if any network or parsing error occurs
    func fetchEpisodes(page: Int = 1) async throws -> EpisodesResponse {
        // Construct the URL for the specific page
        guard let url = URL(string: "\(baseURL)/episode/?page=\(page)") else {
            throw NetworkError.invalidURL
        }
        
        // Make the network request
        let (data, response) = try await URLSession.shared.data(from: url)
        
        // Validate the HTTP response
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        // Parse the JSON response
        do {
            let episodesResponse = try JSONDecoder().decode(EpisodesResponse.self, from: data)
            return episodesResponse
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchCharacter(id: Int) async throws -> APICharacter {
        guard let url = URL(string: "\(baseURL)/character/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let character = try JSONDecoder().decode(APICharacter.self, from: data)
            return character
        } catch {
            throw NetworkError.decodingError
        }
    }
    
    func fetchCharacters(ids: [Int]) async throws -> [APICharacter] {
        let idsString = ids.map { String($0) }.joined(separator: ",")
        guard let url = URL(string: "\(baseURL)/character/\(idsString)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            // API returns array for multiple characters
            let characters = try JSONDecoder().decode([APICharacter].self, from: data)
            return characters
        } catch {
            throw NetworkError.decodingError
        }
    }
    
}

// MARK: - Network Errors

/// Custom errors for network operations
/// Provides localized error messages for better user experience
enum NetworkError: Error, LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError
    
    /// Human-readable error descriptions
    var errorDescription: String? {
        switch self {
            case .invalidURL:
                return "Invalid URL"
            case .invalidResponse:
                return "Invalid response from server"
            case .decodingError:
                return "Failed to decode response"
        }
    }
}
