//
//  ImageRow.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import SwiftUI

struct ImageRow: View {

    let url: URL
    let loader: ImageLoading
    
    @State private var image: Image?
    @State private var isLoading = false

    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                ZStack {
                    Rectangle().fill(.gray.opacity(0.2))
                    if isLoading {
                        ProgressView()
                    }
                }
            }
        }
        .onAppear {
            guard image == nil else { return }
            Task {
                isLoading = true
                await loader.markVisible(url)

                image = try? await loader.loadImage(url)
                isLoading = false
            }
        }
        .onDisappear {
            Task {
                await loader.markPrefetch(url)
                isLoading = false
            }
        }
    }
}
