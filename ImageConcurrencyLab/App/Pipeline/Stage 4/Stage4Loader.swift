//
//  Stage4Loader.swift
//  ImageConcurrencyLab
//
//  Created by max on 20.03.2026.
//

import Foundation

actor Stage4Loader: ImageLoading {
    
    private let provider: ImageDataProvider
    private let cache: ImageCache
    private var inFlightTasks: [URL: Task<Data, Error>] = [:]
    
    private let limit = 6
    private var active = 0
    private var visibleQueue: [URL] = []
    private var prefetchQueue: [URL] = []
    private var waiters: [URL: [CheckedContinuation<Data, Error>]] = [:]
    
    init(provider: ImageDataProvider,
         cache: ImageCache) {
        self.provider = provider
        self.cache = cache
    }
    
    private func pump() {
        guard active < limit else {
            return
        }
        guard !visibleQueue.isEmpty || !prefetchQueue.isEmpty else {
            return
        }
        active += 1
        
        let url = visibleQueue.isEmpty
        ? prefetchQueue.removeFirst()
        : visibleQueue.removeFirst()
        
        let task = Task<Data, Error> {
            try await provider.fetch(url: url)
        }
        inFlightTasks[url] = task
        
        Task {
            do {
                let data = try await task.value
                await cache.set(url, data: data)
                
                finish(url, result: .success(data))
            } catch {
                finish(url, result: .failure(error))
            }
        }
    }
    
    private func finish(_ url: URL, result: Result<Data, Error>) {
        if let continuations = waiters[url] {
            continuations.forEach { continuation in
                continuation.resume(with: result)
            }
            waiters[url] = nil
        }
        
        inFlightTasks[url] = nil
        active -= 1
        pump()
    }
}

extension Stage4Loader {
    
    func load(_ url: URL) async throws -> Data {
        if let data = await cache.get(url) {
            return data
        }
        if let task = inFlightTasks[url] {
            return try await task.value
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            waiters[url, default: []].append(continuation)
            pump()
        }
    }
    
    func markVisible(_ url: URL) {
        guard visibleQueue.firstIndex(of: url) == nil else {
            return
        }
        if let index = prefetchQueue.firstIndex(of: url) {
            prefetchQueue.remove(at: index)
        }
        visibleQueue.append(url)
    }
    
    func markPrefetch(_ url: URL) {
        guard prefetchQueue.firstIndex(of: url) == nil else {
            return
        }
        if let index = visibleQueue.firstIndex(of: url) {
            visibleQueue.remove(at: index)
        }
        prefetchQueue.append(url)
    }
}
