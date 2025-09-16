//
//  TMDBClient.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 10/09/25.
//

import Foundation


enum EndPoint {

    case nowPlaying
    case trendingMovie
    case searchMovie
    case movieWithId(_ id: Int)

    var path: String {
        switch self {
        case .nowPlaying:
            "movie/now_playing"
        case .trendingMovie:
            "trending/movie/day"
        case .searchMovie:
            "search/movie"
        case .movieWithId(let id):
            "movie/\(id)"
        }
    }
}

final class TMDBClient {

    static let shared = TMDBClient()

    private let session: URLSession
    private let baseURL = URL(string: "https://api.themoviedb.org/3")!
    private let jsonDecoder: JSONDecoder
    private let apiKey = Config.getValue(forKey: .apiKey)

    private init(
        session: URLSession = .shared
    ) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.jsonDecoder = decoder
    }

    private func makeURL(path: EndPoint, queryItems: [URLQueryItem] = []) -> URL {
        var components = URLComponents(url: baseURL.appendingPathComponent(path.path), resolvingAgainstBaseURL: false)!
        var items = queryItems
        items.append(URLQueryItem(name: "api_key", value: self.apiKey))
        components.queryItems = items
        return components.url!
    }

    private func perform<T: Decodable>(_ url: URL) async throws -> T {
        let (data, response) = try await session.data(from: url)
        guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
            throw URLError(.badServerResponse)
        }
        return try jsonDecoder.decode(T.self, from: data)
    }

    func fetchTrendingMovies(page: Int) async throws -> PagedResponse<Movie> {
        let url = makeURL(path: .trendingMovie, queryItems: [
            URLQueryItem(name: "page", value: String(page))
        ])
        return try await perform(url)
    }

    func fetchNowPlayingMovies(page: Int) async throws -> PagedResponse<Movie> {
        let url = makeURL(path: .nowPlaying, queryItems: [
            URLQueryItem(name: "page", value: String(page))
        ])
        return try await perform(url)
    }

    func searchMovies(query: String, page: Int) async throws -> PagedResponse<Movie> {
        let url = makeURL(path: .searchMovie, queryItems: [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "include_adult", value: "false")
        ])
        return try await perform(url)
    }

    func fetchMovieDetail(id: Int) async throws -> MovieDetail {
        let url = makeURL(path: .movieWithId(id))
        return try await perform(url)
    }

    // MARK: Images
    static let imageBaseURL = URL(string: "https://image.tmdb.org/t/p/")!
    static func posterURL(path: String?, size: String = "w500") -> URL? {
        guard let path else { return nil }
        return imageBaseURL.appendingPathComponent(size).appendingPathComponent(path)
    }
}

