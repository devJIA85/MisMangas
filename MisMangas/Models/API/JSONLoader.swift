//
//  JSONLoader.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 11/06/2025.
//

import Foundation

func loadLocalJSON<T: Decodable>(filename: String, as type: T.Type) throws -> T {
    guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
        throw APIError.invalidURL
    }
    let data = try Data(contentsOf: url)
    return try JSONDecoder().decode(T.self, from: data)
}
