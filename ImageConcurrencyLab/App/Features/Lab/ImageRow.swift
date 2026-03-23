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
            Task {
                await loader.markVisible(url)

                image = try? await loader.loadImage(url)
            }
        }
        .onDisappear {
            Task {
                await loader.markPrefetch(url)
            }
        }
    }
}
