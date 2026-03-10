//
//  ImageLoading.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//

import Foundation

protocol ImageLoading: Sendable {
    func load(_ url: URL) async throws -> Data
}
