//
//  MisMangasApp.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//
/*
 MisMangas
 │
 ├─ App
 │   └─ MisMangasApp.swift            ← punto de entrada
 │
 ├─ Models
 │   ├─ API                           ← entidades del backend
 │   │   ├─ Manga.swift
 │   │   └─ PaginatedResponse.swift
 │   └─ Persistence                   ← SwiftData
 │       └─ UserManga.swift
 │
 ├─ Networking
 │   └─ APIService.swift              ← llamadas REST, paginación
 │
 ├─ Features
 │   ├─ MangaList                     ← Lista/paginación
 │   │   ├─ MangaListView.swift
 │   │   └─ MangaListViewModel.swift
 │   └─ Collection                    ← “Mi colección”
 │       ├─ CollectionView.swift
 │       └─ CollectionViewModel.swift
 │
 ├─ Shared
 │   ├─ Extensions.swift              ← helpers reutilizables
 │   └─ Constants.swift               ← claves de API, etc.
 │
 ├─ Resources
 │   └─ Assets.xcassets
 │
 ├─ MisMangasTests
 └─ MisMangasUITests
*/
import SwiftUI
import SwiftData

@main
struct MisMangasApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: UserManga.self)
        }
    }
}
