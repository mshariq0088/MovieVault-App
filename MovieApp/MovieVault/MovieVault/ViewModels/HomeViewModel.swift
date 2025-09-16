//
//  HomeViewModel.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 11/09/25.
//

import Foundation
import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    @Published var trending: [Movie] = []
    @Published var nowPlaying: [Movie] = []
    @Published var isLoadingTrending = false
    @Published var isLoadingNowPlaying = false
    @Published var errorMessage: String?

    private let repo: MovieRepositoryType
    private var trendingPage = 1
    private var nowPlayingPage = 1

    init(repo: MovieRepositoryType = MovieRepository()) {
        self.repo = repo
    }

    func loadInitial() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.loadTrending(reset: true) }
            group.addTask { await self.loadNowPlaying(reset: true) }
        }
    }

    func loadTrending(reset: Bool = false) async {
        if reset { trendingPage = 1; trending.removeAll() }
        isLoadingTrending = true
        defer { isLoadingTrending = false }
        do {
            let page = trendingPage
            let list = try await repo.trending(
                isLoadMore: !reset,
                page: page
            )
            trending.append(contentsOf: list)
            trendingPage += 1
        } catch { errorMessage = error.localizedDescription }
    }

    func loadNowPlaying(reset: Bool = false) async {
        if reset { nowPlayingPage = 1; nowPlaying.removeAll() }
        isLoadingNowPlaying = true
        defer { isLoadingNowPlaying = false }
        do {
            let page = nowPlayingPage
            let list = try await repo.nowPlaying(
                isLoadMore: !reset,
                page: page
            )
            nowPlaying.append(contentsOf: list)
            nowPlayingPage += 1
        } catch { errorMessage = error.localizedDescription }
    }
}


