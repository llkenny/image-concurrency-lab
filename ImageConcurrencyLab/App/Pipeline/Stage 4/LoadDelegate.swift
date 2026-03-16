//
//  LoadDelegate.swift
//  ImageConcurrencyLab
//
//  Created by max on 20.03.2026.
//

import Foundation

protocol LoadDelegate: Sendable {
    
    func didLoad(url: URL, data: Data)
}
