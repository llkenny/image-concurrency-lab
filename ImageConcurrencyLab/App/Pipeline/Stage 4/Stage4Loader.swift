//
//  Stage4Loader.swift
//  ImageConcurrencyLab
//
//  Created by max on 19.03.2026.
//

import Foundation

actor Stage4Loader: ImageLoading {
    
    private let provider: ImageDataProvider
    private let cache: ImageCache
    private var inFlightTasks: [URL: Task<Data, Error>] = [:]
    private let limiter: ConcurrencyLimiter
    var loadDelegate: (any LoadDelegate)?
    
    fileprivate var fetchQueue: [URL] = []
    fileprivate var prefetchQueue: [URL] = []
    private var loopActive = false
    
    init(provider: ImageDataProvider,
         cache: ImageCache,
         limiter: ConcurrencyLimiter) {
        self.provider = provider
        self.cache = cache
        self.limiter = limiter
    }
    
    private func startLoop() {
        guard !loopActive else {
            return
        }
        loopActive = true
        while !fetchQueue.isEmpty || !prefetchQueue.isEmpty {
            let url = fetchQueue.isEmpty
            ? prefetchQueue.removeFirst()
            : fetchQueue.removeFirst()
            
            Task {
                let data = try await load(url)
                // FIXME: How to concurrency limit apply?
                await loadDelegate?.didLoad(url: url, data: data)
            }
        }
        loopActive = false
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

// FIXME: Conformance of 'Stage4Loader' to protocol 'MarkVisibility' involves isolation mismatches and can cause data races; this is an error in the Swift 6 language mode
extension Stage4Loader: MarkVisibility {
    
    func markVisible(_ url: URL) async {
        guard fetchQueue.firstIndex(of: url) == nil else {
            return
        }
        if let index = prefetchQueue.firstIndex(of: url) {
            prefetchQueue.remove(at: index)
        }
        fetchQueue.append(url)
        
        startLoop()
    }
    
    func markNotVisible(_ url: URL) async {
        guard prefetchQueue.firstIndex(of: url) == nil else {
            return
        }
        if let index = fetchQueue.firstIndex(of: url) {
            fetchQueue.remove(at: index)
        }
        prefetchQueue.append(url)
    }
}
