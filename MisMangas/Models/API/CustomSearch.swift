//
//  CustomSearch.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 09/06/2025.
//

import Foundation

struct CustomSearch: Codable {
    var searchTitle: String?
    var searchAuthorFirstName: String?
    var searchAuthorLastName: String?
    var searchGenres: [String]?
    var searchThemes: [String]?
    var searchDemographics: [String]?
    var searchContains: Bool
}
