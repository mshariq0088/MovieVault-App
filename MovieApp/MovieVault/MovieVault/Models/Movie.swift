//
//  Movie.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 10/09/25.
//

import Foundation

struct Movie: Identifiable, Codable, Equatable, Hashable {

    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let backdropPath: String?
    let releaseDate: String?
    let voteAverage: Double?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case backdropPath = "backdrop_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
    }
}
