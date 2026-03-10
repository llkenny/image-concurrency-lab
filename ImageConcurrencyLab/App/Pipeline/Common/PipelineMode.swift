//
//  PipelineMode.swift
//  ImageConcurrencyLab
//
//  Created by max on 10.03.2026.
//

enum PipelineMode: String, CaseIterable {
    case stage1Naive
    case stage2SingleFlight
    case stage3ConcurrencyLimit
    case stage4VisibleFirst
    case stage5Cancellation
    case stage6BackgroundDecode
    case stage7BatchedUI
}
