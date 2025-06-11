//
//  SearchView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 09/06/2025.
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @StateObject private var viewModel = SearchViewModel()
    @Environment(\.modelContainer) private var container: ModelContainer

    var body: some View {
        NavigationStack {
            Form {
                Section("Título") {
                    TextField("Buscar por título...", text: $viewModel.searchTitle)
                }
                Section("Autor") {
                    TextField("Nombre (primer)", text: $viewModel.searchAuthorFirstName)
                    TextField("Apellido", text: $viewModel.searchAuthorLastName)
                }
                Section("Opciones de búsqueda") {
                    Toggle("Buscar en título (contains)", isOn: $viewModel.searchContains)
                }
                Section("Géneros (coma separados)") {
                    TextField("e.g. Action,Drama", text: $viewModel.genreTagsText)
                }
                Section("Temas (coma separados)") {
                    TextField("e.g. Psychological,Mystery", text: $viewModel.themeTagsText)
                }
                Section("Demográficos (coma separados)") {
                    TextField("e.g. Shounen,Seinen", text: $viewModel.demographicTagsText)
                }

                Section {
                    Button("Buscar") {
                        Task {
                            let search = CustomSearch(
                                searchTitle: viewModel.searchTitle,
                                searchAuthorFirstName: viewModel.searchAuthorFirstName,
                                searchAuthorLastName: viewModel.searchAuthorLastName,
                                searchGenres: viewModel.genreTagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                                searchThemes: viewModel.themeTagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                                searchDemographics: viewModel.demographicTagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) },
                                searchContains: viewModel.searchContains
                            )
                            await viewModel.performSearch(customSearch: search)
                        }
                    }
                    .disabled(viewModel.isLoading)
                }

                if viewModel.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                }

                if !viewModel.mangas.isEmpty {
                    Section("Resultados") {
                        ForEach(viewModel.mangas, id: \.id) { manga in
                            SearchResultRow(manga: manga)
                        }
                    }
                }
            }
            .navigationTitle("Búsqueda avanzada")
        }
    }
}

private struct SearchResultRow: View {
    let manga: Manga
    @Environment(\.modelContainer) private var container: ModelContainer

    var body: some View {
        NavigationLink {
            MangaDetailView(
                viewModel: MangaDetailViewModel(
                    id: manga.id,
                    title: manga.title,
                    coverURL: URL(string: manga.mainPicture ?? ""),
                    synopsis: manga.sypnosis,
                    genres: (manga.genres ?? []).compactMap { $0.genre },
                    authors: (manga.authors ?? []).map { "\($0.firstName ?? "") \($0.lastName ?? "")" },
                    demographic: (manga.demographics ?? []).compactMap { $0.demographic },
                    themes: (manga.themes ?? []).compactMap { $0.theme },
                    chapters: manga.chapters,
                    volumes: manga.volumes,
                    score: manga.score,
                    status: manga.status,
                    container: container
                )
            )
        } label: {
            Text(manga.title)
        }
    }
}

struct SearchView_Previews: PreviewProvider {X4
    static var previews: some View {
        SearchView()
            .modelContainer(for: Manga.self, inMemory: true)
    }
}
