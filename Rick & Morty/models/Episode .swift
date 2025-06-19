//
//  Episode .swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 17/06/2025.
//

import Foundation
import SwiftData

@Model
final class Episode {
    @Attribute(.unique) var id: Int
    var name: String
    var airDate: String
    var episode: String
    var characters: [URL]
    var url: String
    var created: String
    
    init(id: Int, name: String, airDate: String, episode: String, characters: [URL], url: String, created: String) {
        self.id = id
        self.name = name
        self.airDate = airDate
        self.episode = episode
        self.characters = characters
        self.url = url
        self.created = created
    }
}

// Extension to convert from API response
extension Episode {
    convenience init(from apiEpisode: APIEpisode) {
        let characterURLs = apiEpisode.characters.compactMap { URL(string: $0) }
        
        self.init(
            id: apiEpisode.id,
            name: apiEpisode.name,
            airDate: apiEpisode.airDate,
            episode: apiEpisode.episode,
            characters: characterURLs,
            url: apiEpisode.url,
            created: apiEpisode.created
        )
    }
    
    var seasonNumber: Int {
        // Extract season from format "S01E01" -> 1
        let episodeCode = episode.uppercased()
        if episodeCode.hasPrefix("S"), let sIndex = episodeCode.firstIndex(of: "S") {
            let afterS = episodeCode[episodeCode.index(after: sIndex)...]
            if let eIndex = afterS.firstIndex(of: "E") {
                let seasonString = String(afterS[..<eIndex])
                return Int(seasonString) ?? 1
            }
        }
        return 1 // Default to season 1 if parsing fails
    }
    
    var episodeNumber: Int {
        // Extract episode from format "S01E01" -> 1
        let episodeCode = episode.uppercased()
        if let eIndex = episodeCode.firstIndex(of: "E") {
            let afterE = episodeCode[episodeCode.index(after: eIndex)...]
            return Int(String(afterE)) ?? 1
        }
        return 1 // Default to episode 1 if parsing fails
    }
    
    var characterIDs: [Int] {
        return characters.compactMap { url in
            // Extract ID from URL like "https://rickandmortyapi.com/api/character/1"
            return Int(url.lastPathComponent)
        }
    }
}
