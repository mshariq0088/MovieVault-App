//
//  SearchViewModel.swift
//  MovieVault
//
//  Created by Mohammad Shariq on 11/09/25.
//

import Foundation


@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = "" {
        didSet { debounceSearch() }
    }
    @Published var results: [Movie] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repo: MovieRepositoryType
    private var searchPage = 1
    private var debounceTask: Task<Void, Never>?

    init(repo: MovieRepositoryType = MovieRepository()) {
        self.repo = repo
    }

    func debounceSearch() {
        debounceTask?.cancel()
        let currentQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        debounceTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 500_000_000) // 500ms
            await self?.performSearch(query: currentQuery, reset: true)
        }
    }

    func performSearch(query: String? = nil, reset: Bool = false) async {
        let q = (query ?? self.query).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { results = []; return }
        if reset { searchPage = 1; results.removeAll() }
        isLoading = true
        defer { isLoading = false }
        do {
            let page = searchPage
            let list = try await repo.search(query: q, page: page)
            results.append(contentsOf: list)
            searchPage += 1
        } catch { errorMessage = error.localizedDescription }
    }
}


