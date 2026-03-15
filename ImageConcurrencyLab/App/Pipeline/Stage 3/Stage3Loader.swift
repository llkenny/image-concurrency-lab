//
//  Stage3Loader.swift
//  ImageConcurrencyLab
//
//  Created by max on 13.03.2026.
//
//  cache hit        → bypass limiter
//  in-flight task   → await existing task
//  new task         → pass through limiter

import Foundation

actor Stage3Loader: ImageLoading {
    
    private let provider: ImageDataProvider
    private let cache: ImageCache
    private var inFlightTasks: [URL: Task<Data, Error>] = [:]
    private let limiter: ConcurrencyLimiter
    
    init(provider: ImageDataProvider,
         cache: ImageCache,
         limiter: ConcurrencyLimiter) {
        self.provider = provider
        self.cache = cache
        self.limiter = limiter
    }
    
    func load(_ url: URL) async throws -> Data {
        if let data = await cache.get(url) {
            return data
        }
        if let task = inFlightTasks[url] {
            return try await task.value
        }
        
        await limiter.acquire()
        
        let task = Task<Data, Error> {
            try await provider.fetch(url: url)
        }
        inFlightTasks[url] = task
        
        do {
            let data = try await task.value
            await cache.set(url, data: data)
            inFlightTasks[url] = nil
            
            await limiter.release()
            
            return data
        } catch {
            inFlightTasks[url] = nil
            
            await limiter.release()
            
            throw error
        }
    }
}
