//
//  CollectionView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import SwiftUI
import SwiftData

/// CollectionView.swift
/// Muestra la colección personal de mangas del usuario, leyendo y escribiendo en SwiftData.
struct CollectionView: View {
    // MARK: - Query SwiftData
    /// Obtiene todos los registros `UserManga` de la base en memoria.
    @Query(
        sort: [ SortDescriptor(\UserManga.mangaID, order: .forward) ]
    ) private var userMangas: [UserManga]

    @Environment(\.modelContext) private var context

    /// Default initializer needed for SwiftUI & previews
    init() { }

    // MARK: - UI Body
    var body: some View {
        NavigationView {
            List {
                ForEach(userMangas) { entry in
                    // Navega al detalle externo reusando MangaDetailView
                    NavigationLink(destination: MangaDetailView(id: entry.mangaID)) {
                        HStack(spacing: 12) {
                            // Icono de favorito
                            Image(systemName: entry.isFavorite ? "star.fill" : "star")
                                .foregroundColor(entry.isFavorite ? .yellow : .gray)
                            VStack(alignment: .leading) {
                                // Título con ID (puedes reemplazar por nombre real si lo traes)
                                Text("Manga ID: \(entry.mangaID)")
                                    .font(.headline)
                                // Último capítulo leído
                                if let chap = entry.lastReadChapter {
                                    Text("Leído hasta cap. \(chap)")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Mi Colección")
            .toolbar {
                // Botón de edición (eliminar)
                EditButton()
            }
        }
    }

    // MARK: - Actions
    /// Elimina entradas seleccionadas de la colección SwiftData.
    private func deleteItems(at offsets: IndexSet) {
        for idx in offsets {
            let entry = userMangas[idx]
            // Elimina del store
            context.delete(entry)
        }
    }
}

// MARK: - Preview
#Preview {
    NavigationView {
        CollectionView()
            .modelContainer(for: UserManga.self, inMemory: true)
    }
}
