//
//  PipelineFactory.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//

enum PipelineFactory {
    static var currentMode: PipelineMode = .stage1Naive
    
    static func make(mode: PipelineMode) -> any ImageLoading {
        currentMode = mode
        return switch mode {
            case .stage1Naive:
                Stage1Loader(provider: ImageDataProvider())
            case .stage2SingleFlight:
                Stage2Loader(provider: ImageDataProvider(), cache: ImageCache())
            case .stage3ConcurrencyLimit:
                Stage3Loader(provider: ImageDataProvider(),
                             cache: ImageCache(),
                             limiter: .init(limit: 6))
            case .stage4VisibleFirst:
                Stage4Loader(provider: ImageDataProvider(), cache: ImageCache())
            case .stage5Cancellation:
                Stage5Loader(provider: ImageDataProvider(), cache: ImageCache())
            case .stage6BackgroundDecode:
                Stage6Loader(provider: ImageDataProvider(), cache: Stage6ImageCache())
            default:
                fatalError("Not implemented")
        }
    }
}
