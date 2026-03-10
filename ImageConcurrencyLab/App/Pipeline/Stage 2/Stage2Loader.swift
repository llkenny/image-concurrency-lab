//
//  Stage2Loader.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//
//  Minimal responsibilities:
//  - check completed cache
//  - check in-flight tasks
//  - create a new in-flight task if needed
//  - write completed data to cache
//  - clean in-flight entry on completion
//  Owns:
//  - cache lookup
//  - in-flight deduplication
//  - task cleanup

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
        let task = Task {
            defer {
                inFlightTasks[url] = nil
            }
            let data = try await provider.fetch(url: url)
            await cache.set(url, data: data)
            return data
        }
        inFlightTasks[url] = task
        return try await task.value
    }
}
