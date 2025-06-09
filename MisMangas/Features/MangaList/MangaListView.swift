//
//  MangaListView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import SwiftUI
import SwiftData

struct MangaListView: View {
    // ① Instancia del ViewModel
    @StateObject private var viewModel = MangaListViewModel()
    @Environment(\.modelContext) private var context
    @Query(sort: [SortDescriptor(\UserManga.mangaID, order: .forward)]) private var userMangas: [UserManga]

    /// Binding que controla la presentación de la alerta de error
    private var isErrorPresented: Binding<Bool> {
      Binding(
        get: { viewModel.apiError != nil },
        set: { if !$0 { viewModel.apiError = nil } }
      )
    }

    var body: some View {
        NavigationStack {
            List {
                // ② Iteramos sobre los mangas filtrados por texto de búsqueda
                ForEach(viewModel.mangas.filter { viewModel.query.isEmpty || $0.title.localizedCaseInsensitiveContains(viewModel.query) }) { manga in
                    HStack {
                        NavigationLink(value: manga.id) {
                            Text(manga.title)
                        }
                        .onAppear {
                            // ③ Paginación: cargar más cuando lleguemos al final
                            Task { await viewModel.loadMoreIfNeeded(currentItem: manga) }
                        }
                        Spacer()
                        // Botón favorito
                        Button {
                            if let entry = userMangas.first(where: { $0.mangaID == manga.id }) {
                                context.delete(entry)
                            } else {
                                context.insert(UserManga(mangaID: manga.id))
                            }
                        } label: {
                            Image(systemName: userMangas.contains(where: { $0.mangaID == manga.id }) ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }

                // Indicador de carga en paginación
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
            .navigationTitle("Mangas")
            .alert("Error", isPresented: isErrorPresented) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(viewModel.apiError?.localizedDescription ?? "Error desconocido")
            }
            .navigationDestination(for: Int.self) { mangaID in
                MangaDetailView(id: mangaID)
            }
            .loadingOverlay(isPresented: viewModel.isLoading)
            .task {
                // ④ Carga inicial
                await viewModel.loadAll()
            }
        }
    }
}
