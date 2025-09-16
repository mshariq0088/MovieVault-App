//
//  SavedViewModelTests.swift
//  SavedViewModelTests
//
//  Created by Mohammad Shariq on 16/09/25.
//

import XCTest
@testable import MovieVault

@MainActor
final class SavedViewModelTests: XCTestCase {
    
    private final class MockSavedRepository: MovieRepositoryType {
        var saved: [Movie] = []
        var shouldThrowBookmarks: Bool = false
        
        func trending(isLoadMore: Bool, page: Int) async throws -> [Movie] { [] }
        func nowPlaying(isLoadMore: Bool, page: Int) async throws -> [Movie] { [] }
        func search(query: String, page: Int) async throws -> [Movie] { [] }
        func detail(id: Int) async throws -> MovieDetail { MovieDetail(id: id, title: "D", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, runtime: nil, genres: nil) }
        func toggleBookmark(_ movie: Movie) async throws -> Bool { false }
        
        func bookmarks() throws -> [Movie] {
            if shouldThrowBookmarks { throw NSError(domain: "mock", code: 1) }
            return saved
        }
    }
    
    func makeMovie(id: Int, title: String) -> Movie {
        Movie(id: id, title: title, overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil)
    }
    
    func testLoadSavedBookmarksSuccess() {
        let mock = MockSavedRepository()
        mock.saved = [makeMovie(id: 101, title: "Saved 1")]
        let vm = SavedViewModel(repo: mock)
        
        vm.load()
        
        XCTAssertEqual(vm.saved.count, 1)
        XCTAssertEqual(vm.saved.first?.id, 101)
    }
    
    func testLoadSavedBookmarksError() {
        let mock = MockSavedRepository()
        mock.shouldThrowBookmarks = true
        let vm = SavedViewModel(repo: mock)
        
        vm.load()
        
        XCTAssertEqual(vm.saved.count, 0)
    }
}

