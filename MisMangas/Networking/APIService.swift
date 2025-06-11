// APIService.swift
// MisMangas
//
// Created by Juan Ignacio Antolini on 06/06/2025.

import Foundation

/// Errores posibles de la API de MisMangas.
enum APIError: Error {
    case invalidURL
    case statusCode(Int)
    case decodingFailed
    case requestFailed(Error)
}

/// Servicio encargado de manejar las llamadas a la API de mangas y autores.
final class APIService {
    /// Instancia compartida para acceder al servicio desde cualquier parte de la app.
    static let shared = APIService()
    private init() {}

    /// JSONDecoder configurado para convertir snake_case y decodificar fechas ISO8601.
    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - Endpoints de listados REST

    /// GET /list/mangas?page=...&per=... – Lista paginada de mangas con metadata.
    /// - Parameter page: número de página (por defecto 1)
    /// - Parameter per: elementos por página (por defecto 10)
    /// - Returns: `PaginatedResponse<Manga>` con metadata y datos
    func fetchAllMangas(page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        guard var comps = URLComponents(url: Constants.baseURL.appendingPathComponent("/list/mangas"), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        comps.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per",  value: String(per))
        ]
        let url = comps.url!
        return try await performRequest(url)
    }

    /// GET /list/bestMangas?page=...&per=... – Mangas mejor valorados.
    /// - Parameter page: página (por defecto 1)
    /// - Parameter per: elementos por página (por defecto 10)
    /// - Returns: un arreglo de `Manga` ordenado por puntuación
    func fetchBestMangas(page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        guard var comps = URLComponents(url: Constants.baseURL.appendingPathComponent("/list/bestMangas"), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        comps.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per",  value: String(per))
        ]
        return try await performRequest(comps.url!)
    }
    
    /// GET /list/authors – Lista de todos los autores (no paginada).
    func fetchAuthorsList() async throws -> [Author] {
        let url = Constants.baseURL.appendingPathComponent("/list/authors")
        return try await performArrayRequest(url)
    }

    /// GET /list/demographics – Array de cadenas con demografías.
    func fetchDemographics() async throws -> [String] {
        let url = Constants.baseURL.appendingPathComponent("/list/demographics")
        return try await performArrayRequest(url)
    }

    /// GET /list/genres – Array de cadenas con géneros.
    func fetchGenres() async throws -> [String] {
        let url = Constants.baseURL.appendingPathComponent("/list/genres")
        return try await performArrayRequest(url)
    }

    /// GET /list/themes – Array de cadenas con temáticas.
    func fetchThemes() async throws -> [String] {
        let url = Constants.baseURL.appendingPathComponent("/list/themes")
        return try await performArrayRequest(url)
    }

    /// GET /list/mangaByGenre/{genre} – Mangas de un género específico.
    func fetchMangasByGenre(_ genre: String) async throws -> [Manga] {
        let url = Constants.baseURL.appendingPathComponent("/list/mangaByGenre/\(genre)")
        return try await performArrayRequest(url)
    }

    /// GET /list/mangaByDemographic/{demo} – Mangas de una demografía.
    func fetchMangasByDemographic(_ demo: String) async throws -> [Manga] {
        let url = Constants.baseURL.appendingPathComponent("/list/mangaByDemographic/\(demo)")
        return try await performArrayRequest(url)
    }

    /// GET /list/mangaByTheme/{theme} – Mangas de una temática.
    func fetchMangasByTheme(_ theme: String) async throws -> [Manga] {
        let url = Constants.baseURL.appendingPathComponent("/list/mangaByTheme/\(theme)")
        return try await performArrayRequest(url)
    }

    /// GET /list/mangaByAuthor/{authorID} – Mangas de un autor.
    func fetchMangasByAuthor(_ authorID: String) async throws -> [Manga] {
        let url = Constants.baseURL.appendingPathComponent("/list/mangaByAuthor/\(authorID)")
        return try await performArrayRequest(url)
    }

    // MARK: - Endpoints auxiliares de búsqueda y detalle

    /// GET /search/mangasBeginsWith/{prefix} – Mangas cuyo título empieza por prefix.
    func fetchMangasBeginsWith(_ prefix: String) async throws -> PaginatedResponse<Manga> {
        let url = Constants.baseURL.appendingPathComponent("/search/mangasBeginsWith/\(prefix)")
        return try await performRequest(url)
    }

    /// GET /search/mangasContains/{substring} – Mangas que contienen substring.
    func fetchMangasContains(_ substring: String) async throws -> PaginatedResponse<Manga> {
        let url = Constants.baseURL.appendingPathComponent("/search/mangasContains/\(substring)")
        return try await performRequest(url)
    }

    /// GET /search/author/{name} – Autores que coinciden con nombre.
    func fetchAuthors(matching name: String) async throws -> [Author] {
        let url = Constants.baseURL.appendingPathComponent("/search/author/\(name)")
        return try await performArrayRequest(url)
    }

    /// GET /manga/{id} – Detalle de un manga por ID exacto.
    func fetchManga(id: Int) async throws -> Manga {
        let url = Constants.baseURL.appendingPathComponent("/manga/\(id)")
        return try await performRequest(url)
    }

    /// POST /search/manga – Búsqueda multipropósito con filtros.
    func searchMangas(
        customSearch: CustomSearch,
        page: Int = 1,
        per: Int = 10
    ) async throws -> PaginatedResponse<Manga> {
        guard var comps = URLComponents(url: Constants.baseURL.appendingPathComponent("/search/manga"), resolvingAgainstBaseURL: false) else {
            throw APIError.invalidURL
        }
        comps.queryItems = [
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "per", value: String(per))
        ]
        guard let url = comps.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(customSearch)
        return try await performRequest(request)
    }

    // MARK: - Helpers genéricos de petición

    /// Ejecuta petición GET y decodifica a un tipo Decodable.
    func performRequest<T: Decodable>(_ url: URL) async throws -> T {
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try decoder.decode(T.self, from: data)
    }

    /// Ejecuta petición con URLRequest y decodifica a un tipo Decodable.
    func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        return try decoder.decode(T.self, from: data)
    }

    /// Ejecuta petición GET y decodifica a un array.
    func performArrayRequest<T: Decodable>(_ url: URL) async throws -> [T] {
        return try await performRequest(url)
    }
}


extension APIService: GenresServiceProtocol {}
