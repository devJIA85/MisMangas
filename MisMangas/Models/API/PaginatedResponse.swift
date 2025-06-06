//
//  PaginatedResponse.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import Foundation

/// Representa una respuesta paginada genérica devuelta por los endpoints `/list/*`.
/// - Note: Hace *decode* automático usando las claves `data` y `metadata`.
struct PaginatedResponse<T: Decodable>: Decodable {
    // Map JSON keys to our Swift property names
    private enum CodingKeys: String, CodingKey {
        case data     = "items"
        case metadata = "metadata"
    }
    /// Array de resultados del tipo solicitado.
    let data: [T]
    
    /// Información sobre la paginación (total de ítems, página actual, ítems por página).
    let metadata: Metadata

    struct Metadata: Decodable {
        let total: Int
        let page: Int
        let per: Int
    }
}
