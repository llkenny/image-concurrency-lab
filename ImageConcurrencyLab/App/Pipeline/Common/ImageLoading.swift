//
//  ImageLoading.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//

import SwiftUI

protocol ImageLoading: Sendable {
    func load(_ url: URL) async throws -> Data
    
    // Stage 4+
    func markVisible(_ url: URL) async
    func markPrefetch(_ url: URL) async
    
    // Stage 6+
    func load(_ url: URL) async throws -> Image
}

extension ImageLoading {
    
    func markVisible(_ url: URL) async {}
    func markPrefetch(_ url: URL) async {}
    
    func load(_ url: URL) async throws -> Image {
        fatalError("Not implemented")
    }
}
