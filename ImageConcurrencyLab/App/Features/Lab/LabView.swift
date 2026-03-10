//
//  LabView.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import SwiftUI

struct LabView: View {
    @State var imageLoader: ImageLoading = PipelineFactory.make(mode: .stage2SingleFlight)
    
    var body: some View {
        List(0..<200, id: \.self) { index in
            ImageRow(url: URL(string: "https://example.com/image/\(index).jpg")!, loader: imageLoader)
                .frame(height: 64)
        }
    }
}

#Preview {
    LabView()
}
