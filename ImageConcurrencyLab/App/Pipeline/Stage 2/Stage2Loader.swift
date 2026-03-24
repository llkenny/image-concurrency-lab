//
//  Stage2Loader.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.

import Foundation

actor Stage2Loader {
    
    private let provider: ImageDataProvider
    private let cache: ImageCache
    private var inFlightTasks: [URL: Task<Data, Error>] = [:]
    
    init(provider: ImageDataProvider, cache: ImageCache) {
        self.provider = provider
        self.cache = cache
    }
}

extension Stage2Loader: ImageLoading {
    
    func load(_ url: URL) async throws -> Data {
        if let data = await cache.get(url) {
            return data
        }
        if let task = inFlightTasks[url] {
            return try await task.value
        }
        
        let task = Task<Data, Error> {
            try await provider.fetch(url: url)
        }
        inFlightTasks[url] = task
        
        do {
            let data = try await task.value
            await cache.set(url, data: data)
            inFlightTasks[url] = nil
            return data
        } catch {
            inFlightTasks[url] = nil
            throw error
        }
    }
}
