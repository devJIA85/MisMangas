//
//  MangaDetailView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 08/06/2025.
//

import SwiftUI
import SwiftData

struct MangaDetailView: View {
    // MARK: - Input
    let id: Int
    
    // MARK: - State
    @StateObject private var viewModel: MangaDetailViewModel
    
    // MARK: - Init
    init(id: Int) {
        self.id = id
        _viewModel = StateObject(wrappedValue: MangaDetailViewModel(id: id))
    }
    
    // MARK: - View body
    var body: some View {
        content
            .navigationTitle("Detalle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.toggleFavorite()
                    } label: {
                        Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                    }
                }
            }
            .task {
                await viewModel.load()
            }
    }
    
    // MARK: - Private helpers
    @ViewBuilder
    private var content: some View {
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
                    // Title
                    Text(manga.title)
                        .font(.title)
                        .bold()
                    
                    // English title (optional)
                    if let english = manga.titleEnglish, !english.isEmpty {
                        Text("Título en inglés: \(english)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // Score (optional)
                    if let score = manga.score {
                        Text("Score: \(String(format: "%.2f", score))")
                            .font(.headline)
                    }
                    
                    // Synopsis
                    Text("Sinopsis:")
                        .font(.headline)
                    Text(manga.sypnosis ?? "Sin sinopsis disponible.")
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    // Main picture
                    if
                        let urlString = manga.mainPicture?
                            .trimmingCharacters(in: CharacterSet(charactersIn: "\"")),
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
}
