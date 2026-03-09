//
//  ImageRow.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import SwiftUI

struct ImageRow: View {

    let url: URL

    @State private var image: Image?
    @State private var isLoading = false
    @State private var task: Task<Void, Never>?
    
    private let provider = ImageDataProvider.shared

    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle().fill(.gray.opacity(0.2))
            }
        }
        .onAppear {
            guard image == nil else { return }

            isLoading = true

            task = Task {
                if let data = try? await provider.fetch(url: url) {
                    let uiImage = UIImage(data: data)
                    image = Image(uiImage: uiImage!)
                }
                isLoading = false
            }
        }
    }
}
