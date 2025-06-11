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

@Model
final class UserManga {
    @Attribute(.unique) var mangaID: Int
    var isFavorite: Bool
    var lastReadChapter: Int?
    var notes: String?
    var isComplete: Bool
    var volumesOwnedCount: Int
    var readingVolume: Int?

    init(mangaID: Int, isFavorite: Bool, lastReadChapter: Int?, notes: String?, isComplete: Bool, volumesOwnedCount: Int, readingVolume: Int?) {
        self.mangaID = mangaID
        self.isFavorite = isFavorite
        self.lastReadChapter = lastReadChapter
        self.notes = notes
        self.isComplete = isComplete
        self.volumesOwnedCount = volumesOwnedCount
        self.readingVolume = readingVolume
    }
}

extension UserManga: Codable {
    private enum CodingKeys: String, CodingKey {
        case mangaID, isFavorite, lastReadChapter, notes, isComplete, volumesOwnedCount, readingVolume
    }

    convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let mangaID = try container.decode(Int.self, forKey: .mangaID)
        let isFavorite = try container.decode(Bool.self, forKey: .isFavorite)
        let lastReadChapter = try container.decodeIfPresent(Int.self, forKey: .lastReadChapter)
        let notes = try container.decodeIfPresent(String.self, forKey: .notes)
        let isComplete = try container.decode(Bool.self, forKey: .isComplete)
        let volumesOwnedCount = try container.decode(Int.self, forKey: .volumesOwnedCount)
        let readingVolume = try container.decodeIfPresent(Int.self, forKey: .readingVolume)
        self.init(
            mangaID: mangaID,
            isFavorite: isFavorite,
            lastReadChapter: lastReadChapter,
            notes: notes,
            isComplete: isComplete,
            volumesOwnedCount: volumesOwnedCount,
            readingVolume: readingVolume
        )
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(mangaID, forKey: .mangaID)
        try container.encode(isFavorite, forKey: .isFavorite)
        try container.encodeIfPresent(lastReadChapter, forKey: .lastReadChapter)
        try container.encodeIfPresent(notes, forKey: .notes)
        try container.encode(isComplete, forKey: .isComplete)
        try container.encode(volumesOwnedCount, forKey: .volumesOwnedCount)
        try container.encodeIfPresent(readingVolume, forKey: .readingVolume)
    }
}
