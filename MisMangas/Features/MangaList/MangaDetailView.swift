//
//  MangaDetailView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 08/06/2025.
//


import SwiftUI

struct MangaDetailView: View {
    let mangaID: Int
    @StateObject private var viewModel: MangaDetailViewModel
    
    init(mangaID: Int) {
        self.mangaID = mangaID
        _viewModel = StateObject(wrappedValue: MangaDetailViewModel(id: mangaID))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Cargando manga…")
            } else if let error = viewModel.apiError {
                VStack(spacing: 12) {
                    Text("Error al cargar el manga.")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .padding()
            } else if let manga = viewModel.manga {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(manga.title)
                            .font(.title)
                            .bold()
                        
                        Text("Título en inglés: \(manga.titleEnglish ?? "N/A")")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("Score: \(String(format: "%.2f", manga.score ?? 0.0))")
                            .font(.headline)
                        
                        Text("Sinopsis:")
                            .font(.headline)
                        Text(manga.sypnosis ?? "Sin sinopsis disponible.")
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                        
                        if
                            let urlString = manga.mainPicture?.trimmingCharacters(in: CharacterSet(charactersIn: "\"")),
                            let url = URL(string: urlString)
                        {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                ProgressView()
                            }
                            .frame(maxHeight: 300)
                        }
                    }
                    .padding()
                }
            } else {
                Text("No se encontró el manga.")
            }
        }
        .navigationTitle("Detalle")
        .navigationBarTitleDisplayMode(.inline)
    }
}
