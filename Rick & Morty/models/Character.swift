//
//  Character.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation
import SwiftData

@Model
final class Character {
    @Attribute(.unique) var id: Int
    var name: String
    var status: String
    var species: String
    var type: String
    var gender: String
    var originName: String
    var originUrl: String
    var locationName: String
    var locationUrl: String
    var image: String
    var episodes: [URL]
    var url: String
    var created: String
    
    init(id: Int, name: String, status: String, species: String, type: String, gender: String, originName: String, originUrl: String, locationName: String, locationUrl: String, image: String, episodes: [URL], url: String, created: String) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.originName = originName
        self.originUrl = originUrl
        self.locationName = locationName
        self.locationUrl = locationUrl
        self.image = image
        self.episodes = episodes
        self.url = url
        self.created = created
    }
}

// Extension to convert from API response
extension Character {
    convenience init(from apiCharacter: APICharacter) {
        let episodeURLs = apiCharacter.episode.compactMap { URL(string: $0) }
        
        self.init(
            id: apiCharacter.id,
            name: apiCharacter.name,
            status: apiCharacter.status,
            species: apiCharacter.species,
            type: apiCharacter.type,
            gender: apiCharacter.gender,
            originName: apiCharacter.origin.name,
            originUrl: apiCharacter.origin.url,
            locationName: apiCharacter.location.name,
            locationUrl: apiCharacter.location.url,
            image: apiCharacter.image,
            episodes: episodeURLs,
            url: apiCharacter.url,
            created: apiCharacter.created
        )
    }
    
    // Helper computed properties
    var isAlive: Bool {
        return status.lowercased() == "alive"
    }
    
    var isDead: Bool {
        return status.lowercased() == "dead"
    }
    
    var statusColor: String {
        switch status.lowercased() {
            case "alive":
                return "green"
            case "dead":
                return "red"
            default:
                return "gray"
        }
    }
    
    var episodeIDs: [Int] {
        return episodes.compactMap { url in
            return Int(url.lastPathComponent)
        }
    }
}
