//
//  ConcurrencyLimiter.swift
//  ImageConcurrencyLab
//
//  Created by max on 15.03.2026.
//

actor ConcurrencyLimiter {
    
    private let limit: Int
    private var active = 0
    private var waiters: [CheckedContinuation<Void, Never>] = []
    
    init(limit: Int) {
        self.limit = limit
    }
    
    func acquire() async {
        if active < limit {
            active += 1
            return
        }
        
        await withCheckedContinuation { continuation in
            waiters.append(continuation)
        }
    }
    
    func release() {
        if !waiters.isEmpty {
            let next = waiters.removeFirst()
            next.resume()
        } else {
            active -= 1
        }
    }
}
