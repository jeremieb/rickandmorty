//
//  Character.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation
import SwiftData

@Model
class Character: Identifiable, Codable, Hashable, @unchecked Sendable {
    @Attribute(.unique) var id: Int
    var name: String?
    var status: String?
    var species: String?
    var type: String?
    var gender: String?
    var originName: String?
    var originURL: String?
    var locationName: String?
    var locationURL: String?
    var image: String?
    private var episodeURLsString: String?
    var url: String?
    var created: String?
    
    init(id: Int, name: String? = nil, status: String? = nil, species: String? = nil, type: String? = nil, gender: String? = nil, originName: String? = nil, originURL: String? = nil, locationName: String? = nil, locationURL: String? = nil, image: String? = nil, episodeURLs: [String]? = nil, url: String? = nil, created: String? = nil) {
        self.id = id
        self.name = name
        self.status = status
        self.species = species
        self.type = type
        self.gender = gender
        self.originName = originName
        self.originURL = originURL
        self.locationName = locationName
        self.locationURL = locationURL
        self.image = image
        self.episodeURLsString = episodeURLs?.joined(separator: ",")
        self.url = url
        self.created = created
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, status, species, type, gender, origin, location, image, episode, url, created
    }
    
    /// Computed property to get/set episodeURLs as [String]?
    var episodeURLs: [String]? {
        get {
            guard let episodeURLsString = episodeURLsString, !episodeURLsString.isEmpty else { return nil }
            return episodeURLsString.split(separator: ",").map { String($0) }
        }
        set {
            episodeURLsString = newValue?.joined(separator: ",")
        }
    }

    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        species = try container.decodeIfPresent(String.self, forKey: .species)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        gender = try container.decodeIfPresent(String.self, forKey: .gender)
        
        /// Handle origin location
        if let origin = try container.decodeIfPresent(Location.self, forKey: .origin) {
            originName = origin.name
            originURL = origin.url
        }
        
        /// Handle current location
        if let location = try container.decodeIfPresent(Location.self, forKey: .location) {
            locationName = location.name
            locationURL = location.url
        }
        
        image = try container.decodeIfPresent(String.self, forKey: .image)
        
        /// Convert [String] to comma-separated string
        let episodeURLsArray = try container.decodeIfPresent([String].self, forKey: .episode)
        episodeURLsString = episodeURLsArray?.joined(separator: ",")
        url = try container.decodeIfPresent(String.self, forKey: .url)
        
        created = try container.decodeIfPresent(String.self, forKey: .created)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(status, forKey: .status)
        try container.encodeIfPresent(species, forKey: .species)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(gender, forKey: .gender)
        
        /// Encode origin
        if let originName = originName, let originURL = originURL {
            let origin = Location(name: originName, url: originURL)
            try container.encode(origin, forKey: .origin)
        }
        
        /// Encode location
        if let locationName = locationName, let locationURL = locationURL {
            let location = Location(name: locationName, url: locationURL)
            try container.encode(location, forKey: .location)
        }
        
        try container.encodeIfPresent(image, forKey: .image)
        
        /// Convert comma-separated string back to [String] for encoding
        if let episodeURLsString = episodeURLsString, !episodeURLsString.isEmpty {
            let episodeURLsArray = episodeURLsString.split(separator: ",").map { String($0) }
            try container.encode(episodeURLsArray, forKey: .episode)
        }

        try container.encodeIfPresent(url, forKey: .url)
        try container.encodeIfPresent(created, forKey: .created)
    }
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

struct Location: Codable, Hashable, Sendable {
    let name: String
    let url: String
}

extension Character {
    var origin: Location? {
        guard let originName = originName, let originURL = originURL else { return nil }
        return Location(name: originName, url: originURL)
    }
    
    var location: Location? {
        guard let locationName = locationName, let locationURL = locationURL else { return nil }
        return Location(name: locationName, url: locationURL)
    }
    
    var episode: [String]? {
        return episodeURLs
    }
    
    var formattedStatus: CharacterStatus {
        guard let status = status else { return .unknown }
        return CharacterStatus(rawValue: status) ?? .unknown
    }
    var formattedGender: CharacterGender {
        guard let gender = gender else { return .unknown }
        return CharacterGender(rawValue: gender) ?? .unknown
    }
}

extension Character {
    
    /// Convenience Status
    enum CharacterStatus: String, Sendable {
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "unknown"
    }
    
    /// Convenience genre
    enum CharacterGender: String, Sendable {
        case female = "Female"
        case male = "Male"
        case genderless = "Genderless"
        case unknown = "unknown"
    }
}
