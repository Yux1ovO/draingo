//
//  NodeDetailComponents.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-20.
//

import SwiftUI

struct RiskLevelBadge: View {
    let riskLevel: Int

    var body: some View {
        Text(String(format: "%.1f", Double(riskLevel)))
            .font(.subheadline.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 44, height: 44)
            .background(Circle().fill(RiskLevelStyle.badgeFill(for: riskLevel)))
    }
}

struct NodeDetailGuidanceCard: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.primary)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(RiskLevelStyle.accent, lineWidth: 2)
            )
    }
}

struct NodeDetailReportCard: View {
    let report: FloodReport?

    var body: some View {
        HStack(spacing: 12) {
            reportImage

            Text(report?.message ?? "No reports yet.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(RiskLevelStyle.accent, lineWidth: 2)
        )
    }

    @ViewBuilder
    private var reportImage: some View {
        if let imageUrl = report?.imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    placeholderImage
                case .empty:
                    placeholderImage
                @unknown default:
                    placeholderImage
                }
            }
            .frame(width: 56, height: 56)
            .clipShape(Circle())
        } else {
            placeholderImage
        }
    }

    private var placeholderImage: some View {
        Circle()
            .fill(Color(.systemGray5))
            .frame(width: 56, height: 56)
            .overlay(
                Image(systemName: "photo")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
            )
    }
}

struct NodeDetailAddressCard: View {
    let address: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.secondary)

            Text(address)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.primary)
                .lineLimit(2)

            Spacer(minLength: 0)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(RiskLevelStyle.accent, lineWidth: 2)
        )
    }
}
