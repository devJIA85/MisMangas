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
            // ② Iteramos sobre los mangas filtrados
            ForEach(viewModel.filteredMangas) { manga in
                Text(manga.title)
                    .onAppear {                               // ③ Paginación
                        Task { await viewModel.loadMoreIfNeeded(currentItem: manga) }
                    }
            }
            if viewModel.isLoading && !viewModel.mangas.isEmpty {
                Section {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                }
            }
        }
        .searchable(text: $viewModel.query, prompt: "Buscar manga")
        .navigationTitle("Mangas")                            // título
        .overlay {
            if viewModel.isLoading && viewModel.mangas.isEmpty {
                ProgressView("Cargando...")
            }
        }
        .alert("Error", isPresented: Binding<Bool>(
            get: { viewModel.apiError != nil },
            set: { _ in viewModel.apiError = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.apiError?.localizedDescription ?? "Error desconocido")
        }
        .task {                                               // ④ Carga inicial
            await viewModel.initialLoad()
        }
    }
}
