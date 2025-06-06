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
}
