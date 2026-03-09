//
//  ImageDataProvider.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import UIKit

final class ImageDataProvider {
    
    enum ImageDataProviderError: Error {
        case unknownSymbol
        case noData
    }
    
    public static let shared = ImageDataProvider()
    
    private static let latency: ContinuousClock.Instant.Duration = .milliseconds(200)
    private static let symbols = [
        "star", "heart", "bolt", "flame", "leaf", "bell", "bookmark", "paperplane",
        "cloud", "moon", "sun.max", "hare", "tortoise", "car", "bicycle", "tram",
        "airplane", "globe", "doc", "folder", "trash", "camera", "photo", "person",
        "person.2", "house", "lock", "key", "cart", "gift"
    ]
    
    func fetch(url: URL) async throws -> Data {
        print("FETCH", url)
        // Latency emulation
        try await Task.sleep(for: Self.latency)
        
        let index = abs(url.absoluteString.hashValue) % Self.symbols.count
        let symbol = Self.symbols[index]
        if let data = try generatePngData(for: symbol) {
            return data
        } else {
            throw ImageDataProviderError.noData
        }
    }
    
    private func generatePngData(for symbolName: String) throws -> Data? {
        let config = UIImage.SymbolConfiguration(pointSize: 80, weight: .bold)
        guard let image = UIImage(systemName: symbolName, withConfiguration: config) else {
            throw ImageDataProviderError.unknownSymbol
        }
        
        let renderer = UIGraphicsImageRenderer(size: image.size)
        let img = renderer.image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: image.size))
            UIColor.black.set()
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        return img.pngData()
    }
}
