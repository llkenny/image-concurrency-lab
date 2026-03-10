//
//  LabView.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import SwiftUI

struct LabView: View {

    @State private var selectedStage: PipelineMode = .stage1Naive
    @State private var imageLoader: ImageLoading = PipelineFactory.make(mode: .stage1Naive)
    
    var body: some View {
        NavigationStack {
            List(0..<200, id: \.self) { index in
                ImageRow(url: URL(string: "https://example.com/image/\(index).jpg")!, loader: imageLoader)
                    .frame(height: 64)
            }
            .id(selectedStage)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Picker("Stage", selection: $selectedStage) {
                        ForEach(PipelineMode.allCases) { mode in
                            Text(mode.title).tag(mode)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedStage) { _, newValue in
                        imageLoader = PipelineFactory.make(mode: newValue)
                    }
                }
            }
        }
    }
}

#Preview {
    LabView()
}
