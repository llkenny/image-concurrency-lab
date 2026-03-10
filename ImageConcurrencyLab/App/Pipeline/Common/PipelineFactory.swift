//
//  PipelineFactory.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//

enum PipelineFactory {
    static func make(mode: PipelineMode) -> any ImageLoading {
        switch mode {
            case .stage1Naive:
                return Stage1Loader(provider: ImageDataProvider())
            case .stage2SingleFlight:
                return Stage2Loader(provider: ImageDataProvider(), cache: ImageCache())
            default:
                fatalError("Not implemented")
        }
    }
}
