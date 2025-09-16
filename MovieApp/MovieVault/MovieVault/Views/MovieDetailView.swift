//
//  MovieDetailView.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 11/09/25.
//

import Foundation
import SwiftUI

struct MovieDetailView: View {
    let movie: Movie
    @State private var isBookmarked = false
    private let repo = MovieRepository()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                RemoteImageView(url: TMDBClient.posterURL(path: movie.backdropPath, size: "w780"))
                    .frame(height: 200)
                    .clipped()

                Text(movie.title)
                    .font(.title)
                    .bold()

                if let overview = movie.overview, !overview.isEmpty {
                    Text(overview)
                        .font(.body)
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Button(action: { share() }) { Image(systemName: "square.and.arrow.up") }
                Button(action: { Task { await toggleBookmark() } }) {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                }
            }
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadBookmarkState() }
    }
}

extension MovieDetailView {
    func loadBookmarkState() async {
        do {
            let saved = try repo.bookmarks()
            isBookmarked = saved.contains(where: { $0.id == movie.id })
        } catch { isBookmarked = false }
    }

    func toggleBookmark() async {
        do { isBookmarked = try await repo.toggleBookmark(movie) } catch { }
    }

    func share() {
        let text = "Check out \(movie.title) on MovieVault!"
        let av = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(av, animated: true)
    }
}


