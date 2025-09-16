//
//  PagedResponse.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 10/09/25.
//

import Foundation


struct PagedResponse<T: Codable>: Codable {
    let page: Int
    let results: [T]
    let totalPages: Int
    let totalResults: Int

    enum CodingKeys: String, CodingKey {
        case page
        case results
        case totalPages = "total_pages"
        case totalResults = "total_results"
    }
}
struct PaginationRemoteImage<T: Codable, Equatable> {
    let vote_average : Int
}
