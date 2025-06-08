//
//  UserMangaStore.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 08/06/2025.
//

import Foundation
import SwiftData

/// JSON-backed store para persistir localmente la colección de mangas del usuario.
struct UserMangaStore {
    /// URL del fichero JSON en Documents/userMangas.json
    private static var fileURL: URL {
        let docs = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
        return docs.appendingPathComponent("userMangas.json")
    }

    /// Carga todos los UserManga del disco.
    /// - Returns: Array de UserManga o vacío si no existe el fichero.
    /// - Throws: Error si la lectura/decodificación falla.
    static func loadAll() throws -> [UserManga] {
        let data: Data
        do {
            data = try Data(contentsOf: fileURL)
        } catch {
            // Si no existe el fichero, devolvemos array vacío
            let ns = error as NSError
            if ns.domain == NSCocoaErrorDomain &&
               ns.code == NSFileReadNoSuchFileError {
                return []
            }
            throw error
        }
        // Decodifica JSON a [UserManga]
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode([UserManga].self, from: data)
    }

    /// Guarda el array completo de UserManga al disco de forma atómica.
    /// - Parameter mangas: Lista a codificar y escribir.
    /// - Throws: Error si la codificación o escritura falla.
    static func saveAll(_ mangas: [UserManga]) throws {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(mangas)
        try data.write(to: fileURL, options: .atomicWrite)
    }

    /// Inserta o actualiza un UserManga en la colección local.
    /// - Parameter manga: Entrada a upsertar.
    /// - Throws: Error si carga o guarda fallan.
    static func upsert(_ manga: UserManga) throws {
        var all = try loadAll()
        if let idx = all.firstIndex(where: { $0.mangaID == manga.mangaID }) {
            all[idx] = manga
        } else {
            all.append(manga)
        }
        try saveAll(all)
    }

    /// Elimina el UserManga con el `mangaID` dado.
    /// - Parameter mangaID: ID del manga a borrar.
    /// - Throws: Error si la operación falla.
    static func delete(mangaID: Int) throws {
        let filtered = try loadAll()
            .filter { $0.mangaID != mangaID }
        try saveAll(filtered)
    }
}
