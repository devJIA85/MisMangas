//
//  MangaListViewModel.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 10/06/2025.
//

import Foundation

@MainActor
final class MangaListViewModel: ObservableObject {
    // Lista de mangas obtenida desde el endpoint
    @Published var mangas: [Manga] = []
    // Indica si se está cargando datos
    @Published var isLoading = false
    // Guarda cualquier error ocurrido durante la petición
    @Published var apiError: Error?
    // Término de búsqueda local
    @Published var query: String = ""

    // MARK: - Computed

    /// Devuelve mangas filtrados en base a `query`
    var filteredMangas: [Manga] {
        guard !query.isEmpty else { return mangas }
        return mangas.filter { $0.title.localizedCaseInsensitiveContains(query) }
    }

    // MARK: - Carga de mangas

    /// Carga todos los mangas (GET /list/mangas)
    func loadAll() async {
        isLoading = true
        defer { isLoading = false }

        do {
            mangas = try await APIService.shared.fetchAllMangas().data
        } catch {
            apiError = error
            print("❌ Error al cargar todos los mangas:", error)
        }
    }

    /// Carga los mangas mejor valorados (GET /list/bestMangas)
    func loadBest() async {
        isLoading = true
        defer { isLoading = false }

        do {
            mangas = try await APIService.shared.fetchBestMangas().data
        } catch {
            apiError = error
            print("❌ Error al cargar los mejores mangas:", error)
        }
    }

    // MARK: - Paginación

    /// Carga la página siguiente cuando el `currentItem` sea el último de la lista.
    func loadMoreIfNeeded(currentItem: Manga) async {
        guard let last = mangas.last, currentItem.id == last.id else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            let nextPage = (mangas.count / 10) + 1
            let nuevos = try await APIService.shared.fetchAllMangas(page: nextPage, per: 10).data
            mangas.append(contentsOf: nuevos)
        } catch {
            apiError = error
            print("❌ Error al cargar más mangas:", error)
        }
    }
}
