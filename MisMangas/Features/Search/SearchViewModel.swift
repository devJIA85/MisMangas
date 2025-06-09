//
//  SearchViewModel.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 09/06/2025.
//

import Foundation

/// ViewModel para manejar la lógica de búsqueda multipropósito de mangas.
@MainActor
class SearchViewModel: ObservableObject {
    /// Parametros de búsqueda: título, autor (nombre y apellido), géneros, temáticas, demográficos y modo contains/startsWith
    @Published var searchTitle: String = ""
    @Published var searchAuthorFirstName: String = ""
    @Published var searchAuthorLastName: String = ""
    @Published var searchContains: Bool = false

    /// Text input for comma-separated genre tags
    @Published var genreTagsText: String = ""
    /// Text input for comma-separated theme tags
    @Published var themeTagsText: String = ""
    /// Text input for comma-separated demographic tags
    @Published var demographicTagsText: String = ""

    /// Resultados de la búsqueda paginados
    @Published private(set) var mangas: [Manga] = []
    @Published private(set) var isLoading: Bool = false
    @Published var apiError: Error?

    // MARK: - Métodos

    /// Ejecuta la búsqueda usando los valores actuales de los parámetros.
    func performSearch(page: Int = 1, per: Int = 20) async {
        // Convert comma-separated text into arrays, trimming whitespace and ignoring empty entries
        let genres = genreTagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let themes = themeTagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }
        let demographics = demographicTagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespaces) }
            .filter { !$0.isEmpty }

        // Construir el objeto CustomSearch con los datos ingresados
        let criteria = CustomSearch(
            searchTitle: searchTitle.isEmpty ? nil : searchTitle,
            searchAuthorFirstName: searchAuthorFirstName.isEmpty ? nil : searchAuthorFirstName,
            searchAuthorLastName: searchAuthorLastName.isEmpty ? nil : searchAuthorLastName,
            searchGenres: genres.isEmpty ? nil : genres,
            searchThemes: themes.isEmpty ? nil : themes,
            searchDemographics: demographics.isEmpty ? nil : demographics,
            searchContains: searchContains
        )

        isLoading = true
        defer { isLoading = false }

        do {
            // Llamar al método del servicio de red
            let response = try await APIService.shared.searchMangas(criteria, page: page, per: per)
            //                    ↑ response.items                      ↓ response.data
            // Actualizar los resultados
            mangas = response.data
        } catch {
            // En caso de error, guardarlo para mostrar
            apiError = error
            print("❌ Error al buscar mangas:", error)
        }
    }
}
