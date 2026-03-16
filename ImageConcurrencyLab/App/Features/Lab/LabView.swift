//
//  LabView.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import SwiftUI

struct LabView: View {
    
    @State private var selectedStage: PipelineMode = .stage1Naive
    private let imageCount = 200
    
    var body: some View {
        NavigationStack {
            LabStageView(stage: selectedStage, imageCount: imageCount)
                .id(selectedStage)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Picker("Stage", selection: $selectedStage) {
                        ForEach(PipelineMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                }
            }
        }
    }
}

private struct LabStageView: View {
    
    let stage: PipelineMode
    let imageCount: Int
    
    @StateObject private var viewModel: LabViewModel
    
    init(stage: PipelineMode, imageCount: Int) {
        self.stage = stage
        self.imageCount = imageCount
        _viewModel = StateObject(wrappedValue: LabViewModel(stage: stage))
    }
    
    var body: some View {
        List(0..<imageCount, id: \.self) { index in
            ImageRow(image: viewModel.image(for: url(for: index)),
                     onRowAppear: {
                         viewModel.rowDidAppear(url: url(for: index))
                     },
                     onRowDisappear: {
                         viewModel.rowDidDisappear(url: url(for: index))
                     })
                .frame(height: 120)
        }
    }
    
    private func url(for index: Int) -> URL {
        URL(string: "https://example.com/image/\(index).jpg")!
    }
}

#Preview {
    LabView()
}
