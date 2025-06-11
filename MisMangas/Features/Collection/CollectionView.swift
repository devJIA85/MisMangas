//
//  CollectionView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//


import SwiftUI
import SwiftData

struct CollectionView: View {
    @ObservedObject var viewModel: CollectionViewModel
    @Environment(\.modelContext) private var context: ModelContext

    var body: some View {
        NavigationStack {
            List {
                // Ejemplo: mostrar mangas de la colección
                ForEach(viewModel.userMangas) { userManga in
                    Text("Manga ID: \(userManga.mangaID)")
                    // Personalizá según tu modelo (ej: títulos, autores, etc)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Colección")
            .toolbar {
                EditButton()
            }
        }
        .onAppear {
            viewModel.fetchUserMangas(context: context)
        }
    }

    // Eliminación desde la lista
    private func deleteItems(at offsets: IndexSet) {
        viewModel.deleteUserManga(at: offsets, context: context)
    }
}
