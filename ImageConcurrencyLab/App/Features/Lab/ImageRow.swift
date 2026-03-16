//
//  ImageRow.swift
//  ImageConcurrencyLab
//
//  Created by max on 08.03.2026.
//

import SwiftUI

struct ImageRow: View {

    let image: Image?
    let onRowAppear: () -> Void
    let onRowDisappear: () -> Void

    var body: some View {
        ZStack {
            if let image {
                image
                    .resizable()
                    .scaledToFit()
            } else {
                Rectangle().fill(.gray.opacity(0.2))
            }
        }
        .onAppear(perform: onRowAppear)
        .onDisappear(perform: onRowDisappear)
    }
}
