//
//  Constants.swift
//  ImageConcurrencyLab
//
//  Created by max on 23.03.2026.
//

enum Constants {
    static let networkLatency: ContinuousClock.Instant.Duration = .milliseconds(600)
    nonisolated static let concurrencyLimit = 10
}
