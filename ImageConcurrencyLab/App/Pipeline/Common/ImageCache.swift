//
//  ImageCache.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//
//  Stores completed Data only.

import Foundation

actor ImageCache {
    
    private var cache: [URL: Data] = [:]
    
    func get(_ url: URL) -> Data? {
        cache[url]
    }
    
    func set(_ url: URL, data: Data) {
        cache[url] = data
    }
}
