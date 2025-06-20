//
//  Episode.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation


struct EpisodesResponse: Codable {
    let info: Info
    let results: [Episode]
}

struct Info: Codable {
    let count: Int
    let pages: Int
    let next: URL?
    let prev: URL?
}

struct Episode: Codable, Identifiable, Hashable {
    var id: Int
    var name: String?
    var air_date: String?
    var episode: String?
    var characters: [URL]?
    var url: URL?
    var created: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case air_date
        case episode
        case characters
        case url
        case created
    }
}

extension Episode {
    /// Extract Season Number
    var seasonNumber: Int? {
        // Extract season from format "S01E01" -> 1
        if let episodeCode = episode {
            let uppercased = episodeCode.uppercased()
            if uppercased.hasPrefix("S"), let sIndex = episodeCode.firstIndex(of: "S") {
                let afterS = episodeCode[episodeCode.index(after: sIndex)...]
                if let eIndex = afterS.firstIndex(of: "E") {
                    let seasonString = String(afterS[..<eIndex])
                    return Int(seasonString) ?? 1
                }
            }
            return 1 // Default to season 1 if parsing fails
        } else {
            return nil
        }
    }
    
    /// Extract Episode number
    var episodeNumber: Int? {
        // Extract episode from format "S01E01" -> 1
        if let episodeCode = episode {
            let uppercased = episodeCode.uppercased()
            if let eIndex = uppercased.firstIndex(of: "E") {
                let afterE = episodeCode[episodeCode.index(after: eIndex)...]
                return Int(String(afterE)) ?? 1
            }
            return 1 // Default to episode 1 if parsing fails
        } else {
            return nil
        }
    }
    
    /// Returned the air date to the right format
    var formattedAirDate: String? {
        if let air_date {
            return air_date.formattedDate()
        } else {
            return nil
        }
    }
    
    /// Extracting character ID from the character URL
    var characterIDs: [Int]? {
        if let characters {
            return characters.compactMap { url in
                // Extract ID from URL like "https://rickandmortyapi.com/api/character/1"
                return Int(url.lastPathComponent)
            }
        } else {
            return nil
        }
    }
}
