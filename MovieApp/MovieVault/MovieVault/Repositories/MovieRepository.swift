//
//  MovieRepository.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 10/09/25.
//

import Foundation
import CoreData

protocol MovieRepositoryType {
    func trending(isLoadMore: Bool, page: Int) async throws -> [Movie]
    func nowPlaying(isLoadMore: Bool, page: Int) async throws -> [Movie]
    func search(query: String, page: Int) async throws -> [Movie]
    func detail(id: Int) async throws -> MovieDetail
    func toggleBookmark(_ movie: Movie) async throws -> Bool
    func bookmarks() throws -> [Movie]
}

final class MovieRepository: MovieRepositoryType {
    private let apiClient: TMDBClient
    private let stack: CoreDataStack
    private let expiry: TimeInterval = 60 * 30 // 30 mins

    init(
        api: TMDBClient = .shared,
        stack: CoreDataStack = .shared
    ) {
        self.apiClient = api
        self.stack = stack
    }

    func trending(
        isLoadMore: Bool = true,
        page: Int
    ) async throws -> [Movie] {
        if !isLoadMore {
            if isCacheFresh() {
                return try fetchCached(page: page)
            }
        }
        do {
            let response: PagedResponse<Movie> = try await apiClient.fetchTrendingMovies(page: page)
            cacheMovies(response.results)
            return response.results
        } catch {
            return try fetchCached(page: page)
        }
    }

    func nowPlaying(
        isLoadMore: Bool = true,
        page: Int
    ) async throws -> [Movie] {
        if !isLoadMore {
            if isCacheFresh() {
                return try fetchCached(page: page)
            }
        }
        do {
            let response: PagedResponse<Movie> = try await apiClient.fetchNowPlayingMovies(page: page)
            cacheMovies(response.results)
            return response.results
        } catch {
            return try fetchCached(page: page)
        }
    }

    func search(query: String, page: Int) async throws -> [Movie] {
        let response: PagedResponse<Movie> = try await apiClient.searchMovies(query: query, page: page)
        cacheMovies(response.results)
        return response.results
    }

    func detail(id: Int) async throws -> MovieDetail {
        try await apiClient.fetchMovieDetail(id: id)
    }

    func toggleBookmark(_ movie: Movie) async throws -> Bool {
        let ctx = stack.context
        let entity = try fetchEntity(id: movie.id, in: ctx) ?? MovieEntity(context: ctx)
        entity.update(from: movie)
        entity.isBookmarked.toggle()
        stack.saveIfNeeded()
        return entity.isBookmarked
    }

    func bookmarks() throws -> [Movie] {
        let ctx = stack.context
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "isBookmarked == YES")
        let entities = try ctx.fetch(request)
        return entities.map { $0.toDomain() }
    }

    // MARK: - Private

    private func fetchCached(page: Int) throws -> [Movie] {
        let context = self.stack.context
        var results: [Movie] = []
        try context.performAndWait {
            let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
            request.fetchLimit = 20
            request.fetchOffset = (page - 1) * 20
            request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]

            let entities = try context.fetch(request)
            results = entities.map { $0.toDomain() }
        }
        return results
    }


    private func cacheMovies(_ movies: [Movie]) {
        let ctx = stack.context
        for movie in movies {
            let entity = (try? fetchEntity(id: movie.id, in: ctx)) ?? MovieEntity(context: ctx)
            entity.update(from: movie)
        }
        stack.saveIfNeeded()
    }

    private func isCacheFresh() -> Bool {
        let ctx = stack.context
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "updatedAt", ascending: false)]
        request.fetchLimit = 1
        var result = false
        ctx.performAndWait {
            if let last = try? ctx.fetch(request).first?.updatedAt {
                result = Date().timeIntervalSince(last) < expiry
            }
        }
        return result
    }

    private func fetchEntity(id: Int, in context: NSManagedObjectContext) throws -> MovieEntity? {
        let request: NSFetchRequest<MovieEntity> = MovieEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %lld", id)
        request.fetchLimit = 1
        return try context.fetch(request).first
    }
}

extension MovieEntity {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<MovieEntity> {
        return NSFetchRequest<MovieEntity>(entityName: "MovieEntity")
    }
}


