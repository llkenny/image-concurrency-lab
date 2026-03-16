//
//  MarkVisibility.swift
//  ImageConcurrencyLab
//
//  Created by max on 19.03.2026.
//

import Foundation

protocol MarkVisibility: Sendable {
    
    var loadDelegate: (any LoadDelegate)? { get set }
    
    func markVisible(_ url: URL) async
    func markNotVisible(_ url: URL) async
}
