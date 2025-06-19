//
//  Character.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation

struct Character {
    var id: Int
    var name: String?
    var status: String?
    var species: String?
    var type: String?
    var gender: String?
    var originName: String?
    var originUrl: URL?
    var locationName: String?
    var locationUrl: URL?
    var image: String?
    var episodes: [String]?
    var url: URL?
    var created: String?
}

extension Character {
    
    /// Convenience Status
    enum CharacterStatus: String {
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "unknown"
    }
    
    /// Convenience genre
    enum CharacterGenre: String {
        case female = "Female"
        case male = "Male"
        case genderless = "Genderless"
        case unknown = "unknown"
    }
}
