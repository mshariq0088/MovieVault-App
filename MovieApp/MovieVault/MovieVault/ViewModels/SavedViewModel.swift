//
//  SavedViewModel.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 11/09/25.
//

import Foundation


@MainActor
final class SavedViewModel: ObservableObject {
    @Published var saved: [Movie] = []
    private let repo: MovieRepositoryType

    init(repo: MovieRepositoryType = MovieRepository()) {
        self.repo = repo
    }

    func load() {
        do { saved = try repo.bookmarks() } catch { saved = [] }
    }
}
