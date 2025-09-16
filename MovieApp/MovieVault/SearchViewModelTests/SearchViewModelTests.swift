//
//  SearchViewModelTests.swift
//  SearchViewModelTests
//
//  Created by Mohammad Shariq on 16/09/25.
//

import XCTest
@testable import MovieVault

@MainActor
final class SearchViewModelTests: XCTestCase {
    
    // Mock repo focusing on search
    private final class MockSearchRepository: MovieRepositoryType {
        var pagesForQuery: [String: [[Movie]]] = [:]
        var shouldThrow: Bool = false
        
        func trending(isLoadMore: Bool, page: Int) async throws -> [Movie] { [] }
        func nowPlaying(isLoadMore: Bool, page: Int) async throws -> [Movie] { [] }
        
        func search(query: String, page: Int) async throws -> [Movie] {
            if shouldThrow { throw NSError(domain: "mock", code: 1) }
            let pages = pagesForQuery[query] ?? []
            let idx = max(0, min(page - 1, pages.count - 1))
            return pages.isEmpty ? [] : pages[idx]
        }
        
        func detail(id: Int) async throws -> MovieDetail {
            MovieDetail(id: id, title: "D\(id)", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, runtime: nil, genres: nil)
        }
        
        func toggleBookmark(_ movie: Movie) async throws -> Bool { false }
        func bookmarks() throws -> [Movie] { [] }
    }
    
    func makeMovie(id: Int, title: String) -> Movie {
        Movie(id: id, title: title, overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil)
    }
    
    func testPerformSearchReturnsResults() async {
        let mock = MockSearchRepository()
        mock.pagesForQuery["batman"] = [
            [makeMovie(id: 1, title: "Batman 1"), makeMovie(id: 2, title: "Batman 2")]
        ]
        let vm = SearchViewModel(repo: mock)
        
        await vm.performSearch(query: "batman", reset: true)
        XCTAssertEqual(vm.results.count, 2)
        XCTAssertNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
        
    }
    
    func testPerformSearchPaginationAppendsResults() async {
        let mock = MockSearchRepository()
        mock.pagesForQuery["hero"] = [
            [makeMovie(id: 1, title: "Hero 1")],
            [makeMovie(id: 2, title: "Hero 2")]
        ]
        let vm =  SearchViewModel(repo: mock)
        
        // first page
        await vm.performSearch(query: "hero", reset: true)
        XCTAssertEqual(vm.results.map { $0.id }, [1])
        
        
        // second page (no reset)
        await vm.performSearch(query: "hero", reset: false)
        XCTAssertEqual(vm.results.map { $0.id }, [1, 2])
        
    }
    
    func testPerformSearchErrorSetsErrorMessage() async {
        let mock = MockSearchRepository()
        mock.shouldThrow = true
        let vm =  SearchViewModel(repo: mock)
        
        await vm.performSearch(query: "anything", reset: true)
        
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoading)
    }
}


