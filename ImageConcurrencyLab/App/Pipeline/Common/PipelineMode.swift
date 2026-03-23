//
//  PipelineMode.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//

enum PipelineMode: String, CaseIterable, Identifiable {
    case stage1Naive
    case stage2SingleFlight
    case stage3ConcurrencyLimit
    case stage4VisibleFirst
    case stage5Cancellation
    case stage6BackgroundDecode
    case stage7BatchedUI

    static var allCases: [PipelineMode] {
        [
            .stage1Naive,
            .stage2SingleFlight,
            .stage3ConcurrencyLimit,
            .stage4VisibleFirst,
            .stage5Cancellation,
            .stage6BackgroundDecode,
        ]
    }
    
    var id: String { rawValue }
    
    var title: String {
        switch self {
            case .stage1Naive: return "Naive"
            case .stage2SingleFlight: return "Single flight"
            case .stage3ConcurrencyLimit: return "Concurrency limit"
            case .stage4VisibleFirst: return "Visible first"
            case .stage5Cancellation: return "Cancellation"
            case .stage6BackgroundDecode: return "Background decode"
            case .stage7BatchedUI: return "Batched UI"
        }
    }
}
