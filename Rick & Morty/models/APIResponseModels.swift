//
//  APIResponseModels.swift
//  Rick & Morty
//
//  Created by Jeremie Berduck on 17/06/2025.
//

import Foundation

struct EpisodesResponse: Codable {
    let info: ResponseInfo
    let results: [APIEpisode]
}

struct ResponseInfo: Codable {
    let count: Int
    let pages: Int
    let next: String?
    let prev: String?
}

struct APIEpisode: Codable {
    let id: Int
    let name: String
    let airDate: String
    let episode: String
    let characters: [String]
    let url: String
    let created: String
    
    enum CodingKeys: String, CodingKey {
        case id, name, episode, characters, url, created
        case airDate = "air_date"
    }
}

struct CharactersResponse: Codable {
    let info: ResponseInfo
    let results: [APICharacter]
}

struct APICharacter: Codable {
    let id: Int
    let name: String
    let status: String
    let species: String
    let type: String
    let gender: String
    let origin: APILocation
    let location: APILocation
    let image: String
    let episode: [String]
    let url: String
    let created: String
}

struct APILocation: Codable {
    let name: String
    let url: String
}
