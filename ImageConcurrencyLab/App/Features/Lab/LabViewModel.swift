//
//  LabViewModel.swift
//  ImageConcurrencyLab
//
//  Created by max on 16.03.2026.
//

import Combine
import SwiftUI

@MainActor
final class LabViewModel: ObservableObject {
    
    let stage: PipelineMode
    @Published private(set) var images: [URL: Image] = [:]
    
    private let imageLoader: any ImageLoading
    private let markVisibility: (any MarkVisibility)?
    
    init(stage: PipelineMode) {
        self.stage = stage
        self.imageLoader = PipelineFactory.make(mode: stage)
        
        // Stage 4+
        if var markVisibility = self.imageLoader as? MarkVisibility {
            self.markVisibility = markVisibility
            markVisibility.loadDelegate = self
        } else {
            markVisibility = nil
        }
    }
    
    func image(for url: URL) -> Image? {
        images[url]
    }
    
    func rowDidAppear(url: URL) {
        guard images[url] == nil else {
            return
        }
        Task {
            if let markVisibility {
                await markVisibility.markVisible(url)
            } else {
                guard let data = try? await imageLoader.load(url) else {
                    return
                }
                didLoad(url: url, data: data)
            }
        }
    }
    
    func rowDidDisappear(url: URL) {
        Task {
            await markVisibility?.markNotVisible(url)
        }
    }
}

extension LabViewModel: LoadDelegate {
    
    func didLoad(url: URL, data: Data) {
        guard let uiImage = UIImage(data: data) else {
            return
        }
        images[url] = Image(uiImage: uiImage)
    }
}
