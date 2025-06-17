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
