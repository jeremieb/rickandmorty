//
//  NetworkService.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation

class NetworkService {
    
    static let shared = NetworkService()
    
    /// Basic API URL
    private let baseURL = "https://rickandmortyapi.com/api"
    
    /// Fetch a specific page of episodes from the Rick & Morty API
    ///
    /// - Parameter page: Page number to fetch (defaults to 1)
    /// - Returns: EpisodesResponse containing episodes and pagination info for that specific page
    /// - Throws: NetworkError if any network or parsing error occurs
    func fetchEpisodes(page: Int = 1) async throws -> EpisodesResponse {
        guard let url = URL(string: "\(baseURL)/episode?page=\(page)") else {
            throw NetworkError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase // To convert snake_case to camelCase
            return try decoder.decode(EpisodesResponse.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Convenience Error message
    enum NetworkError: Error, LocalizedError {
        case invalidURL
        case invalidResponse
        case decodingError(Error)
        
        var errorDescription: String? {
            switch self {
                case .invalidURL:
                    return "The URL was invalid."
                case .invalidResponse:
                    return "The server returned an invalid response."
                case .decodingError(let error):
                    return "Failed to decode the response: \(error.localizedDescription)"
            }
        }
    }
}
