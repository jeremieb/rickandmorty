//
//  Episode.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation
import SwiftData

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

/// Swift Data Persistance starts here
@Model
class Episode: Codable, Identifiable, Hashable {
    @Attribute(.unique) var id: Int
    var name: String?
    var air_date: String?
    var episode: String?
    private var charactersURLsString: String?
    var url: String?
    var created: String?
    
    init(id: Int, name: String? = nil, air_date: String? = nil, episode: String? = nil, charactersURLs: [String]? = nil, url: String? = nil, created: String? = nil) {
        self.id = id
        self.name = name
        self.air_date = air_date
        self.episode = episode
        self.charactersURLsString = charactersURLs?.joined(separator: ",")
        self.url = url
        self.created = created
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, air_date, episode, characters, url, created
    }
    
    /// Computed property to get/set charactersURLs as [String]?
    var charactersURLs: [String]? {
        get {
            guard let charactersURLsString = charactersURLsString, !charactersURLsString.isEmpty else { return nil }
            return charactersURLsString.split(separator: ",").map { String($0) }
        }
        set {
            charactersURLsString = newValue?.joined(separator: ",")
        }
    }
    /// Because of the Codable protocol
    /// We transform strings to the required format
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decodeIfPresent(String.self, forKey: .name)
        air_date = try container.decodeIfPresent(String.self, forKey: .air_date)
        episode = try container.decodeIfPresent(String.self, forKey: .episode)
        
        /// Convert [URL] to comma-separated string
        let urlArray = try container.decodeIfPresent([URL].self, forKey: .characters)
        let charactersURLsArray = urlArray?.map { $0.absoluteString }
        charactersURLsString = charactersURLsArray?.joined(separator: ",")
        
        if let urlValue = try container.decodeIfPresent(URL.self, forKey: .url) {
            url = urlValue.absoluteString
        }
        
        created = try container.decodeIfPresent(String.self, forKey: .created)
    }
    
    /// Everything is back to string to be stored
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(air_date, forKey: .air_date)
        try container.encodeIfPresent(episode, forKey: .episode)
        
        /// Convert comma-separated string back to [URL] for encoding
        if let charactersURLsString = charactersURLsString, !charactersURLsString.isEmpty {
            let charactersURLsArray = charactersURLsString.split(separator: ",").map { String($0) }
            let urlArray = charactersURLsArray.compactMap { URL(string: $0) }
            try container.encode(urlArray, forKey: .characters)
        }
        
        if let urlString = url, let urlValue = URL(string: urlString) {
            try container.encode(urlValue, forKey: .url)
        }
        
        try container.encodeIfPresent(created, forKey: .created)
    }
    
    static func == (lhs: Episode, rhs: Episode) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Episode {
    /// Getting the season number for creating sections in the list
    var seasonNumber: Int? {
        if let episodeCode = episode {
            let uppercased = episodeCode.uppercased()
            if uppercased.hasPrefix("S"), let sIndex = episodeCode.firstIndex(of: "S") {
                let afterS = episodeCode[episodeCode.index(after: sIndex)...]
                if let eIndex = afterS.firstIndex(of: "E") {
                    let seasonString = String(afterS[..<eIndex])
                    return Int(seasonString) ?? 1
                }
            }
            return 1
        } else {
            return nil
        }
    }
    
    /// Getting the episode number for display
    var episodeNumber: Int? {
        if let episodeCode = episode {
            let uppercased = episodeCode.uppercased()
            if let eIndex = uppercased.firstIndex(of: "E") {
                let afterE = episodeCode[episodeCode.index(after: eIndex)...]
                return Int(String(afterE)) ?? 1
            }
            return 1
        } else {
            return nil
        }
    }
    
    /// Formatting the air date to the desired format
    var formattedAirDate: String? {
        if let air_date {
            return air_date.formattedDate()
        } else {
            return nil
        }
    }
    
    /// Used to create an Array of character ID per episode
    /// we're also using this to load the character from the API
    var characterIDs: [Int]? {
        if let charactersURLs {
            return charactersURLs.compactMap { urlString in
                if let url = URL(string: urlString) {
                    return Int(url.lastPathComponent)
                }
                return nil
            }
        } else {
            return nil
        }
    }
}
