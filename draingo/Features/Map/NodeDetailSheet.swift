//
//  NodeDetailSheet.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import SwiftUI

struct NodeDetailSheet: View {
    let node: FloodNode
    @State private var viewModel: NodeDetailViewModel
    @State private var isReportSheetPresented: Bool = false

    init(node: FloodNode) {
        self.node = node
        _viewModel = State(initialValue: NodeDetailViewModel(node: node))
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 18) {
                header

                VStack(alignment: .leading, spacing: 10) {
                    sectionTitle("Walking Guidance")
                    NodeDetailGuidanceCard(text: RiskLevelStyle.guidance(for: node.riskLevel))
                }

                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        sectionTitle("User Reports")
                        Spacer()
                        Button("Write report") {
                            isReportSheetPresented = true
                        }
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(RiskLevelStyle.accent)
                    }
                    if viewModel.reports.isEmpty {
                        NodeDetailReportCard(report: nil)
                    } else {
                        ForEach(viewModel.reports) { report in
                            NodeDetailReportCard(report: report)
                        }
                    }
                }

                NodeDetailAddressCard(address: resolvedAddress)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(20)
        }
        .task {
            await viewModel.load()
        }
        .sheet(isPresented: $isReportSheetPresented) {
            NodeReportSheet(node: node) {
                Task { await viewModel.load() }
            }
        }
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 12) {
            RiskLevelBadge(riskLevel: node.riskLevel)

            Text(displayTitle)
                .font(.title3.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(1)

            Spacer(minLength: 8)

            HStack(spacing: 0) {
                Text("\(RiskLevelStyle.label(for: node.riskLevel)) Risk: ")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(depthText)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(RiskLevelStyle.depthColor(for: node.riskLevel))
            }
        }
    }

    private func sectionTitle(_ text: String) -> some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(.secondary)
    }

    private var displayTitle: String {
        if let name = node.name, !name.isEmpty {
            return name
        }
        if !viewModel.addressLine.isEmpty {
            return viewModel.addressLine
        }
        return "Location"
    }

    private var resolvedAddress: String {
        if !viewModel.addressLine.isEmpty {
            return viewModel.addressLine
        }
        return node.name ?? "Location unavailable"
    }

    private var depthText: String {
        guard let depth = node.depthCm else { return "--" }
        return "\(Int(depth.rounded()))cm"
    }
}

#Preview {
    NodeDetailSheet(
        node: FloodNode(
            id: "preview",
            name: "Gilmore Place",
            lat: 55.9533,
            lng: -3.1883,
            riskLevel: 5,
            depthCm: 12.4,
            updatedAt: Date()
        )
    )
}
