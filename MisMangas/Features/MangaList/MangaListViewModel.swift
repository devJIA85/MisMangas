//
//  MangaListViewModel.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//


import Foundation
import Combine

@MainActor
final class MangaListViewModel: ObservableObject {
    @Published private(set) var mangas: [Manga] = []
    private var page = 1
    private let per = 20
    @Published var isLoading = false
    @Published var apiError: Error?
    @Published var query: String = ""

    /// Resulting list after local search
    var filteredMangas: [Manga] {
        query.isEmpty
        ? mangas
        : mangas.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Simple disk cache

    private func cacheURL(for page: Int) -> URL {
        let cachesDir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return cachesDir.appendingPathComponent("mangas_page_\(page).json")
    }

    func initialLoad() async {
        guard mangas.isEmpty else { return }
        await fetchPage(1)
    }

    func loadMoreIfNeeded(currentItem: Manga?) async {
        guard let currentItem = currentItem,
              let lastManga = mangas.last,
              currentItem.id == lastManga.id else { return }
        page += 1
        await fetchPage(page)
    }

    // MARK: - Private helpers
    private func fetchPage(_ pageToLoad: Int) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // 1. Try disk cache first
            let url = cacheURL(for: pageToLoad)
            if let data = try? Data(contentsOf: url) {
                let cachedItems = try JSONDecoder().decode([Manga].self, from: data)
                if pageToLoad == 1 {
                    mangas = cachedItems
                } else {
                    mangas.append(contentsOf: cachedItems)
                }
                return
            }
            
            // 2. Fallback to network
            let response = try await APIService.shared.fetchMangas(page: pageToLoad, per: per)
            let newItems = response.data

            // Cache only the array of mangas for simplicity
            if let encoded = try? JSONEncoder().encode(newItems) {
                try? encoded.write(to: url)
            }

            if pageToLoad == 1 {
                mangas = newItems
            } else {
                mangas.append(contentsOf: newItems)
            }
            
        } catch {
            apiError = error
            print("❌", error)
        }
    }
}
