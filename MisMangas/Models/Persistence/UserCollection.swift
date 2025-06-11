//
//  UserCollection.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 10/06/2025.
//

import Foundation
import SwiftData

@Model
final class UserCollection {
    @Attribute(.unique) var mangaID: Int
    var title: String
    var coverURL: URL
    var volumesOwned: [Int]
    var readingVolume: Int?
    var isComplete: Bool

    init(mangaID: Int, title: String, coverURL: URL, volumesOwned: [Int] = [], readingVolume: Int? = nil, isComplete: Bool = false) {
        self.mangaID = mangaID
        self.title = title
        self.coverURL = coverURL
        self.volumesOwned = volumesOwned
        self.readingVolume = readingVolume
        self.isComplete = isComplete
    }
}
