//
//  ContentView.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List(0..<200, id: \.self) { index in
            ImageRow(url: URL(string: "https://example.com/image/\(index).jpg")!)
                .frame(height: 64)
        }
    }
}

#Preview {
    ContentView()
}
