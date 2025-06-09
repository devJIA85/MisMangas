//
//  Extensions.swift
//  MisMangas
//
//  Created by Juan Ignacio Antolini on 06/06/2025.
//

import SwiftUI

extension String {
    func trimmingQuotes() -> String {
        var result = self
        if result.hasPrefix("\"") {
            result.removeFirst()
        }
        if result.hasSuffix("\"") {
            result.removeLast()
        }
        return result
    }
}

extension URLRequest {
    func addingAppToken() -> URLRequest {
        var request = self
        request.setValue(Constants.appToken, forHTTPHeaderField: "App-Token")
        return request
    }
}

extension View {
    func loadingOverlay(isLoading: Binding<Bool>) -> some View {
        self.overlay(
            Group {
                if isLoading.wrappedValue {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.4))
                }
            }
        )
    }
}

extension View {
    /// Muestra una capa de carga semi-transparente con un spinner.
    /// - Parameter isPresented: Controla si se muestra el overlay.
    /// - Returns: La vista original con el overlay de carga cuando corresponde.
    func loadingOverlay(isPresented: Bool) -> some View {
        ZStack {
            self
            if isPresented {
                // Capa semitransparente que cubre toda la pantalla
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                // Spinner de carga centralizado
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
        }
    }
}
