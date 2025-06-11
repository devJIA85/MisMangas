//
//  UserMangaStore.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 08/06/2025.
//

import Foundation

/// Persistencia opcional en JSON para UserManga (usa el modelo SwiftData @Model definido en otro archivo).
struct UserMangaStore {
    private static var fileURL: URL = {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("userMangas.json")
    }()

    /// Decodifica JSON a un array de UserManga.
    static func loadAll() throws -> [UserManga] {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([UserManga].self, from: data)
    }

    /// Guarda el array completo de UserManga al disco de forma atómica.
    static func saveAll(_ mangas: [UserManga]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(mangas)
        try data.write(to: fileURL, options: .atomic)
    }
}
