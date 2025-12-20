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
        let palette = RiskLevelStyle.palette(for: node.riskLevel)

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
}

#Preview {
    RiskNodeAnnotation(
        node: FloodNode(
            id: "preview",
            name: "Preview",
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
