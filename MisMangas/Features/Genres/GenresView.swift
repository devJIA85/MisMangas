//
//  GenresView.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 09/06/2025.
//

import SwiftUI

// Vista principal que muestra la lista de géneros
struct GenresView: View {
    // ViewModel que maneja lógica y datos de los géneros
    @StateObject private var viewModel = GenresViewModel(genresService: APIService.shared)

    var body: some View {
        NavigationStack {
            // Si hay un error, mostrar mensaje de error
            if let error = viewModel.apiError {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            }
            // Si está cargando, mostrar indicador de progreso
            else if viewModel.isLoading {
                ProgressView("Cargando géneros...")
                    .progressViewStyle(CircularProgressViewStyle())
            }
            // Mostrar la lista de géneros
            else {
                List(viewModel.genres, id: \.self) { genre in
                    Text(genre)
                }
            }
        }
        .onAppear {
            Task {
                await viewModel.loadGenres()
            }
        }
    }
}
