import Foundation
import SwiftUI

/// ViewModel para manejar la lista de mangas en la pantalla principal
@MainActor
final class MangaListViewModel: ObservableObject {
    /// Lista de mangas obtenida desde el endpoint
    @Published var mangas: [Manga] = []
    /// Indicador de carga para mostrar un spinner en la UI
    @Published var isLoading = false
    /// Guarda cualquier error ocurrido durante la petición
    @Published var apiError: Error?

    /// Carga todos los mangas usando el endpoint GET /list/mangas
    func loadAll() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Invoca el servicio de red para traer todos los mangas
            mangas = try await APIService.shared.fetchAllMangas()
        } catch {
            // En caso de error, lo almacenamos para mostrar en la UI
            apiError = error
            print("❌ Error al cargar todos los mangas:", error)
        }
    }

    /// Carga los mangas mejor valorados usando el endpoint GET /list/bestMangas
    func loadBest() async {
        isLoading = true
        defer { isLoading = false }

        do {
            // Invoca el servicio de red para traer los mangas mejor valorados
            mangas = try await APIService.shared.fetchBestMangas()
        } catch {
            // En caso de error, lo almacenamos para mostrar en la UI
            apiError = error
            print("❌ Error al cargar los mejores mangas:", error)
        }
    }
}
