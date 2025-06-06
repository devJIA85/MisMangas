//
//  MangaListView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import SwiftUI

struct MangaListView: View {
    // ① Instancia del ViewModel
    @StateObject private var viewModel = MangaListViewModel()

    var body: some View {
        List {
            // ② Iteramos sobre los mangas
            ForEach(viewModel.mangas) { manga in
                Text(manga.title)
                    .onAppear {                               // ③ Paginación
                        Task { await viewModel.loadMoreIfNeeded(currentItem: manga) }
                    }
            }
        }
        .navigationTitle("Mangas")                            // título
        .task {                                               // ④ Carga inicial
            await viewModel.initialLoad()
        }
    }
}
