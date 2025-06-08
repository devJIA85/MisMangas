//
//  UserManga.swift
//  MisMangas
//
//  Created by Assistant on 2025-06-08.
//
//  This model represents a user's manga entry, stored and managed via SwiftData persistence.
//

import Foundation
import SwiftData

/// A SwiftData model representing a manga entry belonging to the user.
/// Conforms to `Identifiable` for easy use in SwiftUI lists.
@Model class UserManga: Codable, Identifiable {
    // MARK: - Persistent Attributes

    /// Unique identifier for the manga (e.g., the API ID).
    @Attribute(.unique) var mangaID: Int

    /// Indicates if the user has marked this manga as a favorite.
    @Attribute var isFavorite: Bool = false

    /// The last chapter number the user has read.
    @Attribute var lastReadChapter: Int?

    /// Optional personal notes or comments about the manga.
    @Attribute var notes: String?

    // MARK: - Initialization

    /// Creates a new `UserManga` instance for persistence.
    ///
    /// - Parameters:
    ///   - mangaID: The unique ID of the manga.
    ///   - isFavorite: Initial favorite state (defaults to `false`).
    ///   - lastReadChapter: The chapter number last read (defaults to `nil`).
    ///   - notes: Any user notes (defaults to `nil`).
    init(
        mangaID: Int,
        isFavorite: Bool = false,
        lastReadChapter: Int? = nil,
        notes: String? = nil
    ) {
        self.mangaID = mangaID
        self.isFavorite = isFavorite
        self.lastReadChapter = lastReadChapter
        self.notes = notes
    }

    // MARK: - Identifiable Conformance

    /// `Identifiable` protocol requirement, using `mangaID` as the identifier.
    var id: Int { mangaID }

    // MARK: - Codable Conformance
    private enum CodingKeys: String, CodingKey {
        case mangaID, isFavorite, lastReadChapter, notes
    }

    /// Initialize from JSON decoder
    required convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mangaID = try container.decode(Int.self, forKey: .mangaID)
        let isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        let lastReadChapter = try container.decodeIfPresent(Int.self, forKey: .lastReadChapter)
        let notes = try container.decodeIfPresent(String.self, forKey: .notes)
        self.init(mangaID: mangaID, isFavorite: isFavorite, lastReadChapter: lastReadChapter, notes: notes)
    }

    /// Encode to JSON encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mangaID, forKey: .mangaID)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encodeIfPresent(lastReadChapter, forKey: .lastReadChapter)
        try container.encodeIfPresent(notes, forKey: .notes)
    }
}
 
