//
//  MangaDetailViewModel.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 08/06/2025.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
final class MangaDetailViewModel: ObservableObject {
    @Published private(set) var manga: Manga?
    @Published var isLoading = false
    @Published var apiError: Error?
    @Published var isFavorite: Bool = false

    private let id: Int
    private let cacheLifespan: TimeInterval = 60 * 60 * 24 * 7 // 1 semana

    init(id: Int) {
        self.id = id
    }

    private var cacheURL: URL {
        let caches = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
        return caches.appendingPathComponent("manga_\(id).json")
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }

        let url = cacheURL
        if
            let attrs = try? FileManager.default.attributesOfItem(atPath: url.path),
            let created = attrs[.creationDate] as? Date,
            Date().timeIntervalSince(created) < cacheLifespan,
            let data = try? Data(contentsOf: url),
            let cached = try? JSONDecoder().decode(Manga.self, from: data)
        {
            manga = cached
            return
        }

        do {
            let fresh = try await APIService.shared.fetchManga(id: id)
            manga = fresh
            if let encoded = try? JSONEncoder().encode(fresh) {
                try? encoded.write(to: url, options: .atomicWrite)
            }
        } catch {
            self.apiError = error
        }
    }

    /// Toggles the favorite state in SwiftData.
    func toggleFavorite(in context: ModelContext) {
        let targetID = id
        // Build a fetch descriptor for any existing UserManga with this id
        let descriptor = FetchDescriptor<UserManga>(
            predicate: #Predicate { $0.mangaID == targetID }
        )
        if let existing = try? context.fetch(descriptor).first {
            // If it exists, delete it (un-favorite)
            context.delete(existing)
            isFavorite = false
        } else {
            // Otherwise insert a new record (favorite)
            let entry = UserManga(mangaID: id)
            context.insert(entry)
            isFavorite = true
        }
    }

    /// Loads the current favorite state from SwiftData.
    func checkFavorite(in context: ModelContext) {
        let targetID = id
        let descriptor = FetchDescriptor<UserManga>(
            predicate: #Predicate { $0.mangaID == targetID }
        )
        if let existing = try? context.fetch(descriptor).first {
            isFavorite = existing.isFavorite
        } else {
            isFavorite = false
        }
    }
}
