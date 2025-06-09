//
//  APIService.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import Foundation

/// Servicio encargado de manejar las llamadas a la API relacionadas con mangas y autores.
/// Provee métodos para obtener listas paginadas, detalles específicos y búsquedas.
enum APIError: Error {
    case invalidURL, requestFailed, decodingFailed, statusCode(Int)
}

// MARK: - Search Endpoint
extension APIService {
    /// POST /manga – Búsqueda multipropósito con filtros
    func searchMangas(_ customSearch: CustomSearch, page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        // 1. Construir URL del endpoint
        let url = Constants.baseURL.appendingPathComponent("/manga")
        // 2. Configurar la petición HTTP
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // 3. Codificar el cuerpo de la petición
        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        let bodyData = try encoder.encode(customSearch)
        request.httpBody = bodyData
        // 4. Ejecutar la petición
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        // 5. Decodificar respuesta
        return try decoder.decode(PaginatedResponse<Manga>.self, from: data)
    }
}

final class APIService {
    static let shared = APIService()
    private init() {}

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    /// GET /manga/{id} — Devuelve el detalle de un manga
    func fetchManga(id: Int) async throws -> Manga {
      let url = Constants.baseURL.appendingPathComponent("/manga/\(id)")
      var request = URLRequest(url: url)
      request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
      let (data, response) = try await URLSession.shared.data(for: request)
      guard let http = response as? HTTPURLResponse,
            (200..<300).contains(http.statusCode) else {
        throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
      }
      do {
        return try decoder.decode(Manga.self, from: data)
      } catch {
        print("🛑 Error al decodificar detalle de manga:", error.localizedDescription)
        throw APIError.decodingFailed
      }
    }
}

// MARK: - List Endpoints
extension APIService {
    /// GET /list/mangas – Obtiene todos los mangas sin filtros
    /// - Returns: Lista completa de mangas
    func fetchAllMangas() async throws -> [Manga] {
        let url = Constants.baseURL.appendingPathComponent("/list/mangas")
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode([Manga].self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchAllMangas:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchAllMangas:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }

    /// GET /list/bestMangas – Obtiene los mangas mejor valorados
    /// - Returns: Lista completa de mangas mejor valorados
    func fetchBestMangas() async throws -> [Manga] {
        let url = Constants.baseURL.appendingPathComponent("/list/bestMangas")
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode([Manga].self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchBestMangas:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchBestMangas:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }

    /// GET /list/authors – Obtiene lista simple de nombres de autores
    /// - Returns: Lista de nombres de autores
    func fetchAuthorsList() async throws -> [String] {
        let url = Constants.baseURL.appendingPathComponent("/list/authors")
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode([String].self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchAuthorsList:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchAuthorsList:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }

    /// GET /list/demographics – Obtiene lista de demografías disponibles
    /// - Returns: Lista de demografías
    func fetchDemographics() async throws -> [String] {
        let url = Constants.baseURL.appendingPathComponent("/list/demographics")
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode([String].self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchDemographics:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchDemographics:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }

    /// GET /list/genres – Obtiene lista de géneros disponibles
    /// - Returns: Lista de géneros
    func fetchGenres() async throws -> [String] {
        let url = Constants.baseURL.appendingPathComponent("/list/genres")
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode([String].self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchGenres:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchGenres:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }

    /// GET /list/themes – Obtiene lista de temáticas disponibles
    /// - Returns: Lista de temáticas
    func fetchThemes() async throws -> [String] {
        let url = Constants.baseURL.appendingPathComponent("/list/themes")
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode([String].self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchThemes:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchThemes:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }

    /// GET /list/mangaByGenre/{genre} – Obtiene mangas por género
    /// - Parameter genre: nombre del género
    /// - Returns: respuesta paginada con lista de mangas del género
    func fetchMangasByGenre(_ genre: String, page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        var components = URLComponents(
            url: Constants.baseURL.appendingPathComponent("/list/mangaByGenre/\(genre)"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per", value: "\(per)")
        ]
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode(PaginatedResponse<Manga>.self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchMangasByGenre:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchMangasByGenre:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }

    /// GET /list/mangaByDemographic/{demo} – Obtiene mangas por demografía
    /// - Parameter demo: nombre de la demografía
    /// - Returns: respuesta paginada con lista de mangas de esa demografía
    func fetchMangasByDemographic(_ demo: String, page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        var components = URLComponents(
            url: Constants.baseURL.appendingPathComponent("/list/mangaByDemographic/\(demo)"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per", value: "\(per)")
        ]
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode(PaginatedResponse<Manga>.self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchMangasByDemographic:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchMangasByDemographic:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }

    /// GET /list/mangaByTheme/{theme} – Obtiene mangas por temática
    /// - Parameter theme: nombre de la temática
    /// - Returns: respuesta paginada con lista de mangas de esa temática
    func fetchMangasByTheme(_ theme: String, page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        var components = URLComponents(
            url: Constants.baseURL.appendingPathComponent("/list/mangaByTheme/\(theme)"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per", value: "\(per)")
        ]
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode(PaginatedResponse<Manga>.self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchMangasByTheme:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchMangasByTheme:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }

    /// GET /list/mangaByAuthor/{authorID} – Obtiene mangas por autor
    /// - Parameter authorID: identificador del autor
    /// - Returns: respuesta paginada con lista de mangas del autor
    func fetchMangasByAuthor(_ authorID: Int, page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        var components = URLComponents(
            url: Constants.baseURL.appendingPathComponent("/list/mangaByAuthor/\(authorID)"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per", value: "\(per)")
        ]
        guard let url = components?.url else {
            throw APIError.invalidURL
        }
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        let (data, response) = try await URLSession.shared.data(for: request)
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        do {
            return try self.decoder.decode(PaginatedResponse<Manga>.self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError en fetchMangasByAuthor:", decodingError)
            } else {
                print("🛑 Error al decodificar fetchMangasByAuthor:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }
}


// MARK: - Implementación de protocolo para servicio de géneros
extension APIService: GenresServiceProtocol {}
