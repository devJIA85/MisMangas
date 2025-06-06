//
//  ContentView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import SwiftUI
import SwiftData      // acceso a @Query más adelante

struct ContentView: View {
    var body: some View {
        NavigationStack {
            MangaListView()              // ← tu vista principal de la lista
                .navigationTitle("Mangas")   // título inicial
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserManga.self], inMemory: true)
}
