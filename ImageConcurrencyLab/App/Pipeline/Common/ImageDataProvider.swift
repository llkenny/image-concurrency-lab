//
//  ImageDataProvider.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import UIKit

final class ImageDataProvider {
    
    func fetch(url: URL) async throws -> Data {
        try await Task.detached {
            print("FETCH", url)
            try await Task.sleep(for: Constants.networkLatency)
            
            let index = url.absoluteString.filter { $0.isNumber }
            return UIImage(named: "frame\(index)")!.pngData()!
        }.value
    }
}
