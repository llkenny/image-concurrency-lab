//
//  PipelineFactory.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//

enum PipelineFactory {
    static func make(mode: PipelineMode) -> any ImageLoading {
        return switch mode {
            case .stage1Naive:
                Stage1Loader(provider: ImageDataProvider())
            case .stage2SingleFlight:
                Stage2Loader(provider: ImageDataProvider(), cache: ImageCache())
            case .stage3ConcurrencyLimit:
                Stage3Loader(provider: ImageDataProvider(),
                             cache: ImageCache(),
                             limiter: .init(limit: 6))
            default:
                fatalError("Not implemented")
        }
    }
}
