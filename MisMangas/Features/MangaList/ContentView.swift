//
//  ContentView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import SwiftUI
import SwiftData   // SwiftData import reactivado

struct ContentView: View {
    var body: some View {
        NavigationStack {
            MangaListView()
                .navigationTitle("Mangas")
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [UserManga.self], inMemory: true)  // Preview activo con SwiftData
}
