//
//  MangaDetailViewModel.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 08/06/2025.
//

import Foundation
import SwiftUI

@MainActor
final class MangaDetailViewModel: ObservableObject {
    @Published private(set) var manga: Manga?
    @Published var isLoading = false
    @Published var error: Error?

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
                try? encoded.write(to: url, options: .atomic)
            }
        } catch {
            self.error = error
        }
    }
}
