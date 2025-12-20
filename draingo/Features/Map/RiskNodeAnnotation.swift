//
//  RiskNodeAnnotation.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-20.
//

import SwiftUI

struct RiskNodeAnnotation: View {
    let node: FloodNode

    var body: some View {
        let palette = palette(for: node.riskLevel)

        ZStack {
            Circle()
                .fill(palette.outer)
                .frame(width: 62, height: 62)

            Circle()
                .fill(palette.inner)
                .frame(width: 30, height: 30)
                .overlay(
                    Circle()
                        .stroke(palette.stroke, lineWidth: 1.5)
                )

            Text(String(format: "%.1f", Double(node.riskLevel)))
                .font(.caption2.weight(.bold))
                .foregroundStyle(palette.text)
        }
        .shadow(color: palette.outer.opacity(0.35), radius: 6, x: 0, y: 4)
    }

    private func palette(for riskLevel: Int) -> (outer: Color, inner: Color, stroke: Color, text: Color) {
        switch riskLevel {
        case ...2:
            return (
                outer: Color(red: 0.40, green: 0.70, blue: 0.95, opacity: 0.35),
                inner: Color(red: 0.74, green: 0.90, blue: 0.98),
                stroke: Color(red: 0.35, green: 0.62, blue: 0.86),
                text: Color(red: 0.18, green: 0.40, blue: 0.63)
            )
        case 3...5:
            return (
                outer: Color(red: 0.46, green: 0.47, blue: 0.95, opacity: 0.35),
                inner: Color(red: 0.99, green: 0.83, blue: 0.32),
                stroke: Color(red: 0.91, green: 0.72, blue: 0.20),
                text: Color(red: 0.56, green: 0.42, blue: 0.06)
            )
        default:
            return (
                outer: Color(red: 0.74, green: 0.30, blue: 0.42, opacity: 0.35),
                inner: Color(red: 0.96, green: 0.60, blue: 0.56),
                stroke: Color(red: 0.79, green: 0.28, blue: 0.35),
                text: Color(red: 0.44, green: 0.16, blue: 0.22)
            )
        }
    }
}

#Preview {
    RiskNodeAnnotation(
        node: FloodNode(
            id: "preview",
            lat: 55.9533,
            lng: -3.1883,
            riskLevel: 4,
            depthCm: 10.2,
            updatedAt: Date()
        )
    )
    .padding()
    .background(Color(.systemGroupedBackground))
}
