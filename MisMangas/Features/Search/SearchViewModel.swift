//
//  SearchViewModel.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 09/06/2025.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var mangas: [Manga] = []
    @Published var isLoading: Bool = false
    @Published var apiError: Error? = nil
    @Published var searchTitle: String = ""
    @Published var searchAuthorFirstName: String = ""
    @Published var searchAuthorLastName: String = ""
    @Published var searchContains: Bool = false
    @Published var genreTagsText: String = ""
    @Published var themeTagsText: String = ""
    @Published var demographicTagsText: String = ""
    @Published var errorMessage: ErrorMessage?
    
    
    func performSearch(customSearch criteria: CustomSearch, page: Int = 1, per: Int = 10) async {
        isLoading = true
        defer { isLoading = false }
        do {
            // Llamar al método del servicio de red con el label correcto
            let response = try await APIService.shared.searchMangas(customSearch: criteria, page: page, per: per)
            mangas = response.data
        } catch {
            errorMessage = ErrorMessage(message: error.localizedDescription)
            print("❌ Error al buscar mangas:", error)
        }
    }
}
