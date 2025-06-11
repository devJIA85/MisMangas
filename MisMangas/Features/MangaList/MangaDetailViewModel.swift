//
//  MangaDetailViewModel.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 10/06/2025.
//

import Foundation
import SwiftUI
import SwiftData

@MainActor
class MangaDetailViewModel: ObservableObject {
    // MARK: - Inputs
    let id: Int
    let title: String
    let coverURL: URL?
    let synopsis: String?
    let genres: [String]
    let authors: [String]
    let demographic: String?
    let themes: [String]
    let chapters: Int?
    let volumes: Int?
    let score: Double?
    let status: String?

    // MARK: - Estado (UserManga)
    @Published var isFavorite: Bool = false
    @Published var isComplete: Bool = false
    @Published var volumesOwnedCount: Int = 0
    @Published var readingVolume: Int = 0

    // MARK: - Estado remoto/cache
    @Published var isLoading: Bool = false
    @Published var apiError: Error? = nil
    @Published var loadedManga: Manga? = nil
    @Published var isCached: Bool = false

    // MARK: - SwiftData
    private let context: ModelContext

    // MARK: - Init
    init(
        id: Int,
        title: String,
        coverURL: URL?,
        synopsis: String?,
        genres: [String],
        authors: [String],
        demographic: String?,
        themes: [String],
        chapters: Int?,
        volumes: Int?,
        score: Double?,
        status: String?,
        context: ModelContext
    ) {
        self.id = id
        self.title = title
        self.coverURL = coverURL
        self.synopsis = synopsis
        self.genres = genres
        self.authors = authors
        self.demographic = demographic
        self.themes = themes
        self.chapters = chapters
        self.volumes = volumes
        self.score = score
        self.status = status
        self.context = context
        self.checkIfCached()
    }

    // MARK: - User Collection Logic

    func addOrUpdateUserManga() {
        let mangaID = id
        let desc = FetchDescriptor<UserManga>(
            predicate: #Predicate { $0.mangaID == mangaID }
        )
        if let entry = try? context.fetch(desc).first {
            // Update
            entry.isFavorite = isFavorite
            entry.isComplete = isComplete
            entry.volumesOwnedCount = volumesOwnedCount
            entry.readingVolume = readingVolume
        } else {
            // Insert
            let entry = UserManga(
                mangaID: id,
                isFavorite: isFavorite,
                lastReadChapter: nil,
                notes: nil,
                isComplete: isComplete,
                volumesOwnedCount: volumesOwnedCount,
                readingVolume: readingVolume
            )
            context.insert(entry)
        }
        try? context.save()
        checkIfCached()
    }

    func checkIfCached() {
        let mangaID = id
        let desc = FetchDescriptor<UserManga>(
            predicate: #Predicate { $0.mangaID == mangaID }
        )
        if let entry = try? context.fetch(desc).first {
            isFavorite = entry.isFavorite
            isComplete = entry.isComplete
            volumesOwnedCount = entry.volumesOwnedCount
            readingVolume = entry.readingVolume ?? 0
            isCached = true
        } else {
            isFavorite = false
            isComplete = false
            volumesOwnedCount = 0
            readingVolume = 0
            isCached = false
        }
    }

    func removeFromUserCollection() {
        let mangaID = id
        let desc = FetchDescriptor<UserManga>(
            predicate: #Predicate { $0.mangaID == mangaID }
        )
        if let entry = try? context.fetch(desc).first {
            context.delete(entry)
            try? context.save()
            isCached = false
        }
    }

    // MARK: - API Logic
    func fetchRemoteManga() async {
        isLoading = true
        apiError = nil
        do {
            let manga = try await APIService.shared.fetchManga(id: id)
            loadedManga = manga
        } catch {
            apiError = error
        }
        isLoading = false
    }
}
