//
//  FPSChartView.swift
//  ImageConcurrencyLab
//
//  Created by Codex on 23.03.2026.
//

import SwiftUI

struct FPSChartView: View {

    let currentFPS: Double
    let samples: [FPSMonitor.Sample]
    let targetFPS: Double

    private let chartHeight: CGFloat = 84

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text("FPS")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)

                Text("\(Int(currentFPS.rounded()))")
                    .font(.title3.monospacedDigit().weight(.semibold))

                Spacer()

                Text("Target \(Int(targetFPS.rounded()))")
                    .font(.caption.monospacedDigit())
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geometry in
                Canvas { context, size in
                    guard size.width > 0, size.height > 0 else { return }

                    let targetLineY = yPosition(for: targetFPS, height: size.height)
                    var referencePath = Path()
                    referencePath.move(to: CGPoint(x: 0, y: targetLineY))
                    referencePath.addLine(to: CGPoint(x: size.width, y: targetLineY))
                    context.stroke(
                        referencePath,
                        with: .color(.secondary.opacity(0.35)),
                        style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                    )

                    let points = chartPoints(in: size)
                    guard points.count > 1 else { return }

                    var fillPath = Path()
                    fillPath.move(to: CGPoint(x: points[0].x, y: size.height))
                    for point in points {
                        fillPath.addLine(to: point)
                    }
                    fillPath.addLine(to: CGPoint(x: points[points.count - 1].x, y: size.height))
                    fillPath.closeSubpath()

                    context.fill(
                        fillPath,
                        with: .linearGradient(
                            Gradient(colors: [
                                Color.green.opacity(0.35),
                                Color.green.opacity(0.05),
                            ]),
                            startPoint: CGPoint(x: size.width / 2, y: 0),
                            endPoint: CGPoint(x: size.width / 2, y: size.height)
                        )
                    )

                    var linePath = Path()
                    linePath.addLines(points)
                    context.stroke(
                        linePath,
                        with: .color(.green),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                    )
                }
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.black.opacity(0.06))
                )
                .overlay(alignment: .topLeading) {
                    Text("Last 5s")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(8)
                }
                .overlay(alignment: .bottomTrailing) {
                    Text("0")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(8)
                }
                .overlay(alignment: .topTrailing) {
                    Text("\(Int(targetFPS.rounded()))")
                        .font(.caption2.monospacedDigit())
                        .foregroundStyle(.secondary)
                        .padding(8)
                }
            }
            .frame(height: chartHeight)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.regularMaterial)
        )
    }

    private func chartPoints(in size: CGSize) -> [CGPoint] {
        guard let latestTimestamp = samples.last?.timestamp else { return [] }

        let lowerBound = latestTimestamp - 5
        let maxFPS = max(targetFPS, 1)

        return samples.map { sample in
            let xProgress = CGFloat((sample.timestamp - lowerBound) / 5)
            let x = min(max(xProgress, 0), 1) * size.width
            let normalizedFPS = min(max(sample.fps / maxFPS, 0), 1)
            let y = size.height - (CGFloat(normalizedFPS) * size.height)
            return CGPoint(x: x, y: y)
        }
    }

    private func yPosition(for fps: Double, height: CGFloat) -> CGFloat {
        let maxFPS = max(targetFPS, 1)
        let normalizedFPS = min(max(fps / maxFPS, 0), 1)
        return height - (CGFloat(normalizedFPS) * height)
    }
}
