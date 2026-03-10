//
//  Stage1Loader.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//

import Foundation

final class Stage1Loader {
    
    private let provider: ImageDataProvider
    
    init(provider: ImageDataProvider) {
        self.provider = provider
    }
}

extension Stage1Loader: ImageLoading {
    
    func load(_ url: URL) async throws -> Data {
        try await provider.fetch(url: url)
    }
}
