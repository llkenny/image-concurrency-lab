//
//  Constants.swift
//  ImageConcurrencyLab
//
//  Created by max on 23.03.2026.
//

enum Constants {
    static let networkLatency: ContinuousClock.Instant.Duration = .milliseconds(400)
    static let decodingDelay: ContinuousClock.Instant.Duration = .milliseconds(200)
    nonisolated static let concurrencyLimit = 6
}
