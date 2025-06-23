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
    
    /// Generic request method for any Codable type
    ///
    /// - Parameter url: The URL to fetch from
    /// - Returns: Decoded object of type T
    /// - Throws: NetworkError if any network or parsing error occurs
    func request<T: Codable>(url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            // Debug: Print detailed decoding error
            print("❌ JSON Decoding Error for \(url):")
            print("Error: \(error)")
            
            if let decodingError = error as? DecodingError {
                switch decodingError {
                    case .keyNotFound(let key, let context):
                        print("Missing key: \(key.stringValue)")
                        print("Context: \(context)")
                    case .typeMismatch(let type, let context):
                        print("Type mismatch: expected \(type)")
                        print("Context: \(context)")
                    case .valueNotFound(let type, let context):
                        print("Value not found: \(type)")
                        print("Context: \(context)")
                    case .dataCorrupted(let context):
                        print("Data corrupted: \(context)")
                    @unknown default:
                        print("Unknown decoding error")
                }
            }
            print("---")
            
            throw NetworkError.decodingError(error)
        }
    }
    
    /// Fetch a specific character by ID from the Rick & Morty API
    ///
    /// - Parameter id: Character ID to fetch
    /// - Returns: Character object
    /// - Throws: NetworkError if any network or parsing error occurs
    func fetchCharacter(id: Int) async throws -> Character {
        guard let url = URL(string: "\(baseURL)/character/\(id)") else {
            throw NetworkError.invalidURL
        }
        
        return try await request(url: url)
    }
    
    /// Fetch multiple characters by IDs from the Rick & Morty API
    ///
    /// - Parameter ids: Array of character IDs to fetch
    /// - Returns: Array of Character objects
    /// - Throws: NetworkError if any network or parsing error occurs
    func fetchCharacters(ids: [Int]) async throws -> [Character] {
        let idsString = ids.map { String($0) }.joined(separator: ",")
        guard let url = URL(string: "\(baseURL)/character/\(idsString)") else {
            throw NetworkError.invalidURL
        }
        
        return try await request(url: url)
    }
    
    /// Fetch a specific page of episodes from the Rick & Morty API
    ///
    /// - Parameter page: Page number to fetch (defaults to 1)
    /// - Returns: EpisodesResponse containing episodes and pagination info for that specific page
    /// - Throws: NetworkError if any network or parsing error occurs
    func fetchEpisodes(page: Int = 1) async throws -> EpisodesResponse {
        guard let url = URL(string: "\(baseURL)/episode?page=\(page)") else {
            throw NetworkError.invalidURL
        }
        
        return try await request(url: url)
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
