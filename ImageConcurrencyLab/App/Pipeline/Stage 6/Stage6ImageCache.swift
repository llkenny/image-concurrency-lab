//
//  Stage6ImageCache.swift
//  ImageConcurrencyLab
//
//  Created by max on 23.03.2026.
//

import SwiftUI

actor Stage6ImageCache {
    
    private var cache: [URL: Image] = [:]
    
    func get(_ url: URL) -> Image? {
        cache[url]
    }
    
    func set(_ url: URL, image: Image) {
        cache[url] = image
    }
}
