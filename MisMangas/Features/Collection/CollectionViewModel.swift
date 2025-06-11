//
//  CollectionViewModel.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import Foundation
import SwiftData
import Combine

@MainActor
final class CollectionViewModel: ObservableObject {
    // Publicada para que la View observe los cambios
    @Published var userMangas: [UserManga] = []

    // MARK: - Traer toda la colección del usuario desde SwiftData
    func fetchUserMangas(context: ModelContext) {
        let descriptor = FetchDescriptor<UserManga>(
            sortBy: [SortDescriptor(\.mangaID, order: .forward)]
        )
        do {
            userMangas = try context.fetch(descriptor)
        } catch {
            print("❌ Error al fetchUserMangas: \(error.localizedDescription)")
            userMangas = []
        }
    }

    // MARK: - Eliminar manga del usuario
    func deleteUserManga(at offsets: IndexSet, context: ModelContext) {
        for index in offsets {
            let mangaToDelete = userMangas[index]
            context.delete(mangaToDelete)
        }
        do {
            try context.save()
            fetchUserMangas(context: context)
        } catch {
            print("❌ Error al eliminar manga: \(error.localizedDescription)")
        }
    }
}
