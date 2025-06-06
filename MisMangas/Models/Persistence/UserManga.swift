//
//  UserManga.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//


import Foundation
import SwiftData          // ← imprescindible para @Model

@Model
final class UserManga {
    @Attribute(.unique) var mangaID: Int      // id del manga en la API
    var title: String                         // título, para mostrar sin llamada extra
    var volumesOwned: [Int] = []              // tomos que tienes
    var readingVolume: Int?                   // tomo en lectura (opcional)
    var completeCollection: Bool = false      // ¿ya la completaste?
    var dateAdded: Date                       // para ordenar por “Recientes”

    init(mangaID: Int, title: String, dateAdded: Date = Date()) {
        self.mangaID = mangaID
        self.title = title
        self.dateAdded = dateAdded
    }
}
