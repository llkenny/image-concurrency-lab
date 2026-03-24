//
//  FPSMonitor.swift
//  ImageConcurrencyLab
//
//  Created by Codex on 23.03.2026.
//

import Combine
import QuartzCore
import SwiftUI
import UIKit

@MainActor
final class FPSMonitor: NSObject, ObservableObject {

    struct Sample: Identifiable {
        let id = UUID()
        let timestamp: CFTimeInterval
        let fps: Double
    }

    @Published private(set) var currentFPS: Double = 0
    @Published private(set) var samples: [Sample] = []
    @Published private(set) var targetFPS: Double = 60

    private let historyWindow: CFTimeInterval = 5
    private let publishInterval: CFTimeInterval = 0.2
    private var displayLink: CADisplayLink?
    private var previousTimestamp: CFTimeInterval?
    private var pendingSamples: [Sample] = []
    private var lastPublishedTimestamp: CFTimeInterval?

    func start() {
        guard displayLink == nil else { return }

        targetFPS = Double(
            UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.screen.maximumFramesPerSecond }
                .first ?? 60
        )

        let link = CADisplayLink(target: self, selector: #selector(handleDisplayLink(_:)))
        link.add(to: .main, forMode: .common)
        displayLink = link
    }

    func stop() {
        displayLink?.invalidate()
        displayLink = nil
        previousTimestamp = nil
        lastPublishedTimestamp = nil
        pendingSamples.removeAll(keepingCapacity: true)
        currentFPS = 0
        samples.removeAll(keepingCapacity: true)
    }

    @objc
    private func handleDisplayLink(_ link: CADisplayLink) {
        defer { previousTimestamp = link.timestamp }

        guard let previousTimestamp else { return }

        let frameDuration = max(link.timestamp - previousTimestamp, 0.0001)
        let fps = min(1.0 / frameDuration, targetFPS)
        let sample = Sample(timestamp: link.timestamp, fps: fps)

        pendingSamples.append(sample)

        if shouldPublish(now: link.timestamp) {
            currentFPS = fps
            samples.append(contentsOf: pendingSamples)
            pendingSamples.removeAll(keepingCapacity: true)
            trimSamples(now: link.timestamp)
            lastPublishedTimestamp = link.timestamp
        }
    }

    private func trimSamples(now: CFTimeInterval) {
        let cutoff = now - historyWindow
        samples.removeAll { $0.timestamp < cutoff }
    }

    private func shouldPublish(now: CFTimeInterval) -> Bool {
        guard let lastPublishedTimestamp else { return true }
        return now - lastPublishedTimestamp >= publishInterval
    }
}
