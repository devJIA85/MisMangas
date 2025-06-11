//
//  MangaListView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 10/06/2025.
//

import SwiftUI
import SwiftData

struct MangaListView: View {
    @StateObject private var viewModel = MangaListViewModel()
    @Environment(\.modelContext) private var context: ModelContext

    var body: some View {
        NavigationStack {
            List {
                // Mostrar cada manga filtrado
                ForEach(viewModel.filteredMangas, id: \.id) { manga in
                    NavigationLink(value: manga.id) {
                        Text(manga.title)
                            .padding(.vertical, 4)
                    }
                    .onAppear {
                        // Paginación: carga más si es el último
                        Task {
                            await viewModel.loadMoreIfNeeded(currentItem: manga)
                        }
                    }
                }
                
                // Indicador de carga en la parte inferior
                if viewModel.isLoading {
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
            .navigationTitle("Mangas")
            .alert("Error", isPresented: Binding(
                get: { viewModel.apiError != nil },
                set: { if !$0 { viewModel.apiError = nil } }
            )) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.apiError?.localizedDescription ?? "Error desconocido")
            }
            .navigationDestination(for: Int.self) { mangaID in
                MangaDetailView(
                    viewModel: MangaDetailViewModel(
                        id: mangaID,
                        title: "",
                        coverURL: nil,
                        synopsis: nil,
                        genres: [],
                        authors: [],
                        demographic: nil,
                        themes: [],
                        chapters: nil,
                        volumes: nil,
                        score: nil,
                        status: nil,
                        context: context
                    )
                )
            }
        }
        .task {
            // Carga inicial
            await viewModel.loadAll()
        }
    }
}

#Preview {
    MangaListView()
}
