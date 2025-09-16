//
//  HomeViewModelTests.swift
//  HomeViewModelTests
//
//  Created by Mohammad Shariq on 16/09/25.
//

import XCTest
@testable import MovieVault


@MainActor
final class HomeViewModelTests: XCTestCase {
    
    private final class MockMovieRepository: MovieRepositoryType {
        var trendingPages: [[Movie]] = []
        var nowPlayingPages: [[Movie]] = []
        var shouldThrow: Bool = false
        
        func trending(isLoadMore: Bool, page: Int) async throws -> [Movie] {
            if shouldThrow { throw NSError(domain: "mock", code: 1) }
            let idx = max(0, min(page - 1, trendingPages.count - 1))
            return trendingPages.isEmpty ? [] : trendingPages[idx]
        }
        
        func nowPlaying(isLoadMore: Bool, page: Int) async throws -> [Movie] {
            if shouldThrow { throw NSError(domain: "mock", code: 1) }
            let idx = max(0, min(page - 1, nowPlayingPages.count - 1))
            return nowPlayingPages.isEmpty ? [] : nowPlayingPages[idx]
        }
        
        
        func search(query: String, page: Int) async throws -> [Movie] {
            return []
        }
        
        
        func detail(id: Int) async throws -> MovieDetail {
            return MovieDetail(id: id, title: "Detail \(id)", overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil, runtime: nil, genres: nil)
        }
        
        
        func toggleBookmark(_ movie: Movie) async throws -> Bool { return false }
        func bookmarks() throws -> [Movie] { return [] }
    }
    
    func makeMovie(id: Int, title: String) -> Movie {
        Movie(id: id, title: title, overview: nil, posterPath: nil, backdropPath: nil, releaseDate: nil, voteAverage: nil)
    }
    
    func testLoadTrendingSuccess() async {
        let mock = MockMovieRepository()
        // page 1 data
        mock.trendingPages = [
            [makeMovie(id: 1, title: "A"), makeMovie(id: 2, title: "B")]
        ]
        let vm =  HomeViewModel(repo: mock)
        
        await vm.loadTrending(reset: true)
        XCTAssertEqual(vm.trending.count, 2)
        XCTAssertEqual(vm.trending[0].id, 1)
        XCTAssertFalse(vm.isLoadingTrending)
        XCTAssertNil(vm.errorMessage)
        
    }
    
    func testLoadNowPlayingSuccess() async {
        let mock = MockMovieRepository()
        mock.nowPlayingPages = [
            [makeMovie(id: 10, title: "Now1")]
        ]
        let vm =  HomeViewModel(repo: mock)
        
        await vm.loadNowPlaying(reset: true)
        
        XCTAssertEqual(vm.nowPlaying.count, 1)
        XCTAssertEqual(vm.nowPlaying[0].id, 10)
        XCTAssertFalse(vm.isLoadingNowPlaying)
        XCTAssertNil(vm.errorMessage)
        
    }
    
    func testLoadInitialLoadsBothSections() async {
        let mock = MockMovieRepository()
        mock.trendingPages = [
            [makeMovie(id: 1, title: "A")]
        ]
        mock.nowPlayingPages = [
            [makeMovie(id: 2, title: "B")]
        ]
        let vm =  HomeViewModel(repo: mock)
        
        await vm.loadInitial()
        
        XCTAssertEqual(vm.trending.count, 1)
        XCTAssertEqual(vm.nowPlaying.count, 1)
        XCTAssertNil(vm.errorMessage)
        
    }
    
    func testLoadTrendingErrorSetsErrorMessage() async {
        let mock = MockMovieRepository()
        mock.shouldThrow = true
        let vm =  HomeViewModel(repo: mock)
        
        await vm.loadTrending(reset: true)
        
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoadingTrending)
        
    }
    
    func testLoadNowPlayingErrorSetsErrorMessage() async {
        let mock = MockMovieRepository()
        mock.shouldThrow = true
        let vm =  HomeViewModel(repo: mock)
        
        await vm.loadNowPlaying(reset: true)
        
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertFalse(vm.isLoadingNowPlaying)
        
    }
}
