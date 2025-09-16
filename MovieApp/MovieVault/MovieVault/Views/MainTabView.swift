//
//  MainTabView.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 11/09/25.
//

import Foundation
import SwiftUI

struct MainTabView: View {
    @EnvironmentObject private var router: Router
    @State private var deepLinkMovie: Movie?
    @State private var presentDetail = false

    var body: some View {
        TabView {
            HomeView()
                .tabItem { Label("Home", systemImage: "house") }

            SearchView()
                .tabItem { Label("Search", systemImage: "magnifyingglass") }

            SavedView()
                .tabItem { Label("Saved", systemImage: "bookmark") }
        }
        .onReceive(router.$target) { target in
            guard let target else { return }
            Task {
                do {
                    let detail = try await TMDBClient.shared.fetchMovieDetail(id: target.id)
                    deepLinkMovie = Movie(
                        id: detail.id,
                        title: detail.title,
                        overview: detail.overview,
                        posterPath: detail.posterPath,
                        backdropPath: detail.backdropPath,
                        releaseDate: detail.releaseDate,
                        voteAverage: detail.voteAverage
                    )
                    presentDetail = true
                } catch { }
            }
        }
        .sheet(isPresented: $presentDetail, onDismiss: { router.target = nil }) {
            if let movie = deepLinkMovie {
                NavigationStack { MovieDetailView(movie: movie) }
            }
        }
    }
}

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    var body: some View {
        NavigationStack {
            List {
                Section("Trending") {
                    ForEach(viewModel.trending) { movie in
                        NavigationLink(value: movie) {
                            HStack(spacing: 12) {
                                RemoteImageView(url: TMDBClient.posterURL(path: movie.posterPath))
                                    .frame(width: 60, height: 90)
                                    .cornerRadius(6)
                                VStack(alignment: .leading) {
                                    Text(movie.title).font(.headline)
                                    if let date = movie.releaseDate { Text(date).font(.subheadline).foregroundColor(.secondary) }
                                }
                            }
                        }
                    }
                    if viewModel.isLoadingTrending { ProgressView().frame(maxWidth: .infinity) }
                    Button("Load more") { Task { await viewModel.loadTrending() } }
                }
                Section("Now Playing") {
                    ForEach(viewModel.nowPlaying) { movie in
                        NavigationLink(value: movie) {
                            HStack(spacing: 12) {
                                RemoteImageView(url: TMDBClient.posterURL(path: movie.posterPath))
                                    .frame(width: 60, height: 90)
                                    .cornerRadius(6)
                                VStack(alignment: .leading) {
                                    Text(movie.title).font(.headline)
                                    if let date = movie.releaseDate { Text(date).font(.subheadline).foregroundColor(.secondary) }
                                }
                            }
                        }
                    }
                    if viewModel.isLoadingNowPlaying { ProgressView().frame(maxWidth: .infinity) }
                    Button("Load more") { Task { await viewModel.loadNowPlaying() } }
                }
            }
            .navigationDestination(for: Movie.self) { movie in MovieDetailView(movie: movie) }
            .navigationTitle("MovieVault")
            .task { await viewModel.loadInitial() }
            .refreshable { await viewModel.loadInitial() }
        }
    }
}

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    var body: some View {
        NavigationStack {
            List {
                Section {
                    TextField("Search movies", text: $viewModel.query)
                }
                Section {
                    ForEach(viewModel.results) { movie in
                        NavigationLink(destination: MovieDetailView(movie: movie)) {
                            HStack(spacing: 12) {
                                RemoteImageView(url: TMDBClient.posterURL(path: movie.posterPath))
                                    .frame(width: 50, height: 75)
                                    .cornerRadius(6)
                                Text(movie.title)
                            }
                        }
                    }
                    if viewModel.isLoading { ProgressView().frame(maxWidth: .infinity) }
                }
            }
            .navigationTitle("Search")
        }
    }
}

struct SavedView: View {
    @StateObject private var viewModel = SavedViewModel()
    var body: some View {
        NavigationStack {
            List {
                ForEach(viewModel.saved) { movie in
                    NavigationLink(destination: MovieDetailView(movie: movie)) {
                        HStack(spacing: 12) {
                            RemoteImageView(url: TMDBClient.posterURL(path: movie.posterPath))
                                .frame(width: 50, height: 75)
                                .cornerRadius(6)
                            Text(movie.title)
                        }
                    }
                }
            }
            .navigationTitle("Saved")
            .onAppear { viewModel.load() }
        }
    }
}


