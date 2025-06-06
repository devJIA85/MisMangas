//
//  Manga.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import Foundation

// MARK: - Nested helpers

struct Author: Codable, Hashable {
    let id: String
    let firstName: String
    let lastName: String
    let role: String?
}

struct Genre: Codable, Hashable {
    let id: String
    let genre: String
}

struct Theme: Codable, Hashable {
    let id: String
    let theme: String
}

struct Demographic: Codable, Hashable {
    let id: String
    let demographic: String
}

// MARK: - Manga model

struct Manga: Identifiable, Codable, Hashable {
    let id: Int
    let title: String
    let titleEnglish: String?
    let titleJapanese: String?
    let mainPicture: String?
    let score: Double?
    let status: String?
    let chapters: Int?
    let volumes: Int?

    let authors: [Author]?
    let genres: [Genre]?
    let themes: [Theme]?
    let demographics: [Demographic]?

    let sypnosis: String?
    let background: String?
    let url: String?

    let startDate: String?
    let endDate: String?
}
