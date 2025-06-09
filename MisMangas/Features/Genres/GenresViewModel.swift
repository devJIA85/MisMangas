//
//  GenresViewModel.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 09/06/2025.
//

import Foundation

/// ViewModel encargado de gestionar la lógica y datos relacionados con los géneros de manga.
@MainActor
class GenresViewModel: ObservableObject {
    /// Lista de géneros disponibles.
    @Published var genres: [String] = []
    
    /// Indica si los géneros se están cargando.
    @Published var isLoading: Bool = false
    
    /// Error ocurrido durante la carga de géneros, si existe.
    @Published var apiError: Error? = nil
    
    private let genresService: GenresServiceProtocol
    
    /// Inicializa el ViewModel con un servicio para obtener géneros.
    /// - Parameter genresService: Servicio que provee los géneros.
    init(genresService: GenresServiceProtocol) {
        self.genresService = genresService
    }
    
    /// Carga la lista de géneros desde el servicio.
    func loadGenres() async {
        isLoading = true
        apiError = nil
        defer { isLoading = false }
        do {
            genres = try await genresService.fetchGenres()
        } catch {
            apiError = error
        }
    }
}

/// Protocolo que define la interfaz para un servicio que obtiene géneros.
protocol GenresServiceProtocol {
    /// Obtiene una lista de géneros.
    func fetchGenres() async throws -> [String]
}
