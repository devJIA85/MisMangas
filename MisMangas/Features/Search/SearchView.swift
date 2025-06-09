//
//  SearchView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 09/06/2025.
//

import SwiftUI

struct SearchView: View {
    // MARK: - ViewModel
    @StateObject private var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            // Formulario de búsqueda avanzada
            Form {
                // Sección para título
                Section("Título") {
                    TextField("Buscar por título...", text: $viewModel.searchTitle)
                }
                // Sección para autor
                Section("Autor") {
                    TextField("Nombre (primer)", text: $viewModel.searchAuthorFirstName)
                    TextField("Apellido", text: $viewModel.searchAuthorLastName)
                }
                // Sección para opciones de búsqueda
                Section("Opciones de búsqueda") {
                    Toggle("Buscar en título (contains)", isOn: $viewModel.searchContains)
                }
                // Sección para géneros (coma separados)
                Section("Géneros (coma separados)") {
                    TextField("e.g. Action,Drama", text: $viewModel.genreTagsText)
                }
                // Sección para temas (coma separados)
                Section("Temas (coma separados)") {
                    TextField("e.g. Psychological,Mystery", text: $viewModel.themeTagsText)
                }
                // Sección para demográficos (coma separados)
                Section("Demográficos (coma separados)") {
                    TextField("e.g. Shounen,Seinen", text: $viewModel.demographicTagsText)
                }
                // Botón para iniciar la búsqueda
                Section {
                    Button("Buscar") {
                        Task {
                            await viewModel.performSearch()
                        }
                    }
                    .disabled(viewModel.isLoading)
                }
                // Indicador de carga mientras se realiza la búsqueda
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
            .navigationTitle("Búsqueda avanzada")
            // Lista de resultados debajo del formulario
            List {
                // Sección de resultados
                Section("Resultados") {
                    ForEach(viewModel.mangas, id: \.id) { manga in
                        NavigationLink(value: manga.id) {
                            Text(manga.title)
                        }
                    }
                }
            }
            .navigationDestination(for: Int.self) { id in
                MangaDetailView(id: id)
            }
        }
    }
}

// Vista previa de SearchView
struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView()
    }
}
