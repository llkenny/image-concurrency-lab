//
//  ImageLoading.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//

import SwiftUI

protocol ImageLoading: Sendable {
    func load(_ url: URL) async throws -> Data
    func loadImage(_ url: URL) async throws -> Image
    
    // Stage 4+
    func markVisible(_ url: URL) async
    func markPrefetch(_ url: URL) async
}

extension ImageLoading {

    private var imageDecoder: EnhancedImageDecoder {
        EnhancedImageDecoder()
    }
    
    func markVisible(_ url: URL) async {}
    func markPrefetch(_ url: URL) async {}
    
    func loadImage(_ url: URL) async throws -> Image {
        let data = try await load(url)
        let uiImage = try imageDecoder.decode(data)
        return Image(uiImage: uiImage)
    }
}
