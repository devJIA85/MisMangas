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
    @Query(sort: [SortDescriptor<UserManga>(\.mangaID, order: .forward)]) private var userMangas: [UserManga]

    var body: some View {
        List {
            // ② Iteramos sobre los mangas filtrados
            ForEach(viewModel.filteredMangas) { manga in
                HStack {
                    NavigationLink(value: manga.id) {
                        Text(manga.title)
                    }
                    .onAppear {                               // ③ Paginación
                        Task { await viewModel.loadMoreIfNeeded(currentItem: manga) }
                    }
                    Spacer()
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
