//
//  Character.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 19/06/2025.
//

import Foundation

struct Character: Identifiable, Decodable, Encodable {
    var id: Int
    var name: String?
    var status: String?
    var species: String?
    var type: String?
    var gender: String?
    var origin: Location?
    var location: Location?
    var image: String?
    var episode: [String]?
    var url: String?
    var created: String?
}

struct Location: Codable, Hashable {
    let name: String
    let url: String
}

extension Character {
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
    enum CharacterStatus: String {
        case alive = "Alive"
        case dead = "Dead"
        case unknown = "unknown"
    }
    
    /// Convenience genre
    enum CharacterGender: String {
        case female = "Female"
        case male = "Male"
        case genderless = "Genderless"
        case unknown = "unknown"
    }
}
