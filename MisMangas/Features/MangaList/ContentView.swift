//
//  ContentView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject private var collectionVM = CollectionViewModel()

    var body: some View {
        TabView {
            NavigationStack {
                MangaListView()
                    .navigationTitle("Mangas")
            }
            .tabItem {
                Label("Mangas", systemImage: "book")
            }

            NavigationStack {
                // NO pases el container explícitamente, solo el viewModel si hace falta
                CollectionView(viewModel: collectionVM)
                    .navigationTitle("Colección")
            }
            .tabItem {
                Label("Colección", systemImage: "star")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: UserManga.self, inMemory: true)
}
