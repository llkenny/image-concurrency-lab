//
//  Stage6Loader.swift
//  ImageConcurrencyLab
//
//  Created by max on 23.03.2026.
//

import SwiftUI

actor Stage6Loader: ImageLoading {
    
    private let provider: ImageDataProvider
    private let cache: Stage6ImageCache
    private var inFlightTasks: [URL: Task<Image, Error>] = [:]
    
    private let limit = 6
    private var active = 0
    private var visibleQueue: [URL] = []
    private var prefetchQueue: [URL] = []
    private var waiters: [URL: [CheckedContinuation<Image, Error>]] = [:]
    
    init(provider: ImageDataProvider,
         cache: Stage6ImageCache) {
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
        
        let task = Task<Image, Error> {
            let data = try await provider.fetch(url: url)
            
            try Task.checkCancellation()
            
            let image = await decode(data)
            await cache.set(url, image: image)
            
            return image
        }
        inFlightTasks[url] = task
        
        Task {
            do {
                let image = try await task.value
                finish(url, result: .success(image))
            } catch {
                finish(url, result: .failure(error))
            }
        }
    }
    
    private func decode(_ data: Data) async -> Image {
        await Task.detached(priority: .utility) {
            let uiImage = UIImage(data: data)!
            return Image(uiImage: uiImage)
        }.value
    }
    
    private func finish(_ url: URL, result: Result<Image, Error>) {
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

extension Stage6Loader {
    
    func load(_ url: URL) async throws -> Data {
        fatalError("Stage 6 provides Image version of the method")
    }
    
    func load(_ url: URL) async throws -> Image {
        if let image = await cache.get(url) {
            return image
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
        if let index = visibleQueue.firstIndex(of: url) {
            visibleQueue.remove(at: index)
            prefetchQueue.append(url)
        }
        
        inFlightTasks[url]?.cancel()
    }
}
