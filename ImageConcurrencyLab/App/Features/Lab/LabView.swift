//
//  LabView.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import SwiftUI

struct LabView: View {

    @State private var selectedStage: PipelineMode = .stage1Naive
    @State private var imageLoader: any ImageLoading = PipelineFactory.make(mode: .stage1Naive)
    private let imageCount = 186
    @StateObject private var fpsMonitor = FPSMonitor()
    
    var body: some View {
        NavigationStack {
            List(0..<imageCount, id: \.self) { index in
                ImageRow(url: URL(string: "https://example.com/image/\(index).jpg")!,
                         loader: imageLoader)
                    .frame(height: 120)
            }
            .id(selectedStage)
            .safeAreaInset(edge: .bottom, spacing: 0) {
                FPSChartView(
                    currentFPS: fpsMonitor.currentFPS,
                    samples: fpsMonitor.samples,
                    targetFPS: fpsMonitor.targetFPS
                )
                .padding(.horizontal, 12)
                .padding(.top, 8)
                .padding(.bottom, 8)
                .background(.ultraThinMaterial)
                .allowsHitTesting(false)
            }
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
        .onAppear {
            fpsMonitor.start()
        }
        .onDisappear {
            fpsMonitor.stop()
        }
        .onChange(of: selectedStage) { _, newValue in
            imageLoader = PipelineFactory.make(mode: newValue)
        }
    }
}

#Preview {
    LabView()
}
