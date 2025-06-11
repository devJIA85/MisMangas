import SwiftUI
import SwiftData

struct MangaDetailView: View {
    @ObservedObject var viewModel: MangaDetailViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let url = viewModel.coverURL {
                AsyncImage(url: url) { image in
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                } placeholder: {
                    ProgressView()
                }
                .frame(height: 220)
                .cornerRadius(10)
            }

            Text(viewModel.title)
                .font(.largeTitle).bold()
            if let author = viewModel.authors.first {
                Text("Autor: \(author)")
            }
            if let demo = viewModel.demographic {
                Text("Demografía: \(demo)")
            }
            if let genre = viewModel.genres.first {
                Text("Género: \(genre)")
            }
            if let theme = viewModel.themes.first {
                Text("Temática: \(theme)")
            }
            if let status = viewModel.status {
                Text("Estado: \(status)")
            }
            if let chapters = viewModel.chapters {
                Text("Capítulos: \(chapters)")
            }
            if let volumes = viewModel.volumes {
                Text("Volúmenes: \(volumes)")
            }
            if let score = viewModel.score {
                Text("Puntaje: \(score, specifier: "%.2f")")
            }
            if let synopsis = viewModel.synopsis {
                Text(synopsis)
                    .font(.body)
            }

            Spacer()

            HStack {
                Button(action: {
                    viewModel.isFavorite.toggle()
                    viewModel.addOrUpdateUserManga()
                }) {
                    Image(systemName: viewModel.isFavorite ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                    Text(viewModel.isFavorite ? "Favorito" : "Agregar a favoritos")
                }

                Button(action: {
                    viewModel.removeFromUserCollection()
                }) {
                    Image(systemName: "trash")
                    Text("Quitar de colección")
                }
                .foregroundColor(.red)
            }

            if viewModel.isLoading {
                ProgressView("Cargando manga...")
            }
            if let error = viewModel.apiError {
                Text("Ocurrió un error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .onAppear {
            Task {
                await viewModel.fetchRemoteManga()
            }
        }
    }
}
