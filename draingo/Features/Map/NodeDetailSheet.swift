//
//  NodeDetailSheet.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import SwiftUI

struct NodeDetailSheet: View {
    let node: FloodNode

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Risk \(node.riskLevel)")
                .font(.title2.bold())

            if let depth = node.depthCm {
                Text("Depth: \(depth, specifier: "%.1f") cm")
                    .font(.body)
            }

            Text("Updated \(node.updatedAt.formatted(date: .abbreviated, time: .shortened))")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}

#Preview {
    NodeDetailSheet(
        node: FloodNode(
            id: "preview",
            lat: 55.9533,
            lng: -3.1883,
            riskLevel: 5,
            depthCm: 12.4,
            updatedAt: Date()
        )
    )
}
