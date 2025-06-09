//
//  APIService.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import Foundation

enum APIError: Error {
    case invalidURL, requestFailed, decodingFailed, statusCode(Int)
}

/// Servicio encargado de manejar las llamadas a la API relacionadas con mangas y autores.
/// Provee métodos para obtener listas paginadas, detalles específicos y búsquedas.
final class APIService {
    static let shared = APIService()
    private init() {}

    private let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    /// GET /list/mangas?page&per  – Versión básica paginada
    /// - Parameters:
    ///   - page: página a obtener (default 1)
    ///   - per: cantidad de ítems por página (default 10)
    /// - Returns: respuesta paginada con lista de mangas
    func fetchMangas(page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {

        // 1. Construir la URL con parámetros
        var components = URLComponents(
            url: Constants.baseURL.appendingPathComponent("/list/mangas"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per",  value: "\(per)")
        ]

        guard let url = components?.url else {
            throw APIError.invalidURL
        }

        // 2. Solicitud y cabecera de autenticación
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")

        // 3. Ejecución
        let (data, response) = try await URLSession.shared.data(for: request)
        // DEBUG: inspeccionar JSON bruto
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")

        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }

        // 4. Decodificación
        do {
            return try decoder.decode(PaginatedResponse<Manga>.self, from: data)
        } catch {
            // Imprime la causa exacta del fallo de decodificación
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError:", decodingError)
            } else {
                print("🛑 Error al decodificar:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }
    
    /// GET /manga/{id} – Fetch single manga detail
    /// - Parameter id: identificador del manga
    /// - Returns: objeto Manga con detalle completo
    func fetchManga(id: Int) async throws -> Manga {
        let url = Constants.baseURL.appendingPathComponent("/manga/\(id)")
        
        var request = URLRequest(url: url)
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        print(String(data: data, encoding: .utf8) ?? "⚠️ No se pudo convertir data a String")
        
        guard let http = response as? HTTPURLResponse,
              (200..<300).contains(http.statusCode) else {
            throw APIError.statusCode((response as? HTTPURLResponse)?.statusCode ?? -1)
        }
        
        do {
            return try decoder.decode(Manga.self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError:", decodingError)
            } else {
                print("🛑 Error al decodificar:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }
    
    /// GET /list/mangas/beginsWith?letter&page&per – Obtiene mangas cuyo título comienza con una letra específica
    /// - Parameters:
    ///   - beginsWith: letra con la que debe comenzar el título
    ///   - page: página a obtener (default 1)
    ///   - per: cantidad de ítems por página (default 10)
    /// - Returns: respuesta paginada con lista de mangas
    func fetchMangas(beginsWith letter: String, page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        var components = URLComponents(
            url: Constants.baseURL.appendingPathComponent("/list/mangas/beginsWith"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "letter", value: letter),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per",  value: "\(per)")
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
            return try decoder.decode(PaginatedResponse<Manga>.self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError:", decodingError)
            } else {
                print("🛑 Error al decodificar:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }
    
    /// GET /list/mangas/contains?text&page&per – Obtiene mangas cuyo título contiene un texto específico
    /// - Parameters:
    ///   - contains: texto que debe contener el título
    ///   - page: página a obtener (default 1)
    ///   - per: cantidad de ítems por página (default 10)
    /// - Returns: respuesta paginada con lista de mangas
    func fetchMangas(contains text: String, page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        var components = URLComponents(
            url: Constants.baseURL.appendingPathComponent("/list/mangas/contains"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "text", value: text),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per",  value: "\(per)")
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
            return try decoder.decode(PaginatedResponse<Manga>.self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError:", decodingError)
            } else {
                print("🛑 Error al decodificar:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }
    
    /// GET /list/authors?name&page&per – Obtiene autores cuyo nombre coincide con un texto específico
    /// - Parameters:
    ///   - matching: texto que debe coincidir en el nombre del autor
    ///   - page: página a obtener (default 1)
    ///   - per: cantidad de ítems por página (default 10)
    /// - Returns: respuesta paginada con lista de autores
    func fetchAuthors(matching name: String, page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Author> {
        var components = URLComponents(
            url: Constants.baseURL.appendingPathComponent("/list/authors"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "name", value: name),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per",  value: "\(per)")
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
            return try decoder.decode(PaginatedResponse<Author>.self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError:", decodingError)
            } else {
                print("🛑 Error al decodificar:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }
    
    /// GET /search/mangas?query&page&per – Busca mangas por texto libre
    /// - Parameters:
    ///   - query: texto de búsqueda
    ///   - page: página a obtener (default 1)
    ///   - per: cantidad de ítems por página (default 10)
    /// - Returns: respuesta paginada con lista de mangas que coinciden con la búsqueda
    func searchMangas(_ query: String, page: Int = 1, per: Int = 10) async throws -> PaginatedResponse<Manga> {
        var components = URLComponents(
            url: Constants.baseURL.appendingPathComponent("/search/mangas"),
            resolvingAgainstBaseURL: false
        )
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "per",  value: "\(per)")
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
            return try decoder.decode(PaginatedResponse<Manga>.self, from: data)
        } catch {
            if let decodingError = error as? DecodingError {
                print("🛑 DecodingError:", decodingError)
            } else {
                print("🛑 Error al decodificar:", error.localizedDescription)
            }
            throw APIError.decodingFailed
        }
    }
}
