//
//  FloodSearchCard.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import SwiftUI

struct FloodSearchCard: View {
    @Binding var query: String
    let onPinTap: () -> Void
    let onSearch: () -> Void

    private var actionBlue: Color {
        Color(red: 0.262, green: 0.247, blue: 0.854)
    }

    var body: some View {
        VStack(spacing: 18) {

            VStack(alignment: .leading, spacing: 12) {
                Text("Find flooded areas nearby")
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 10) {
                    Button(action: onPinTap) {
                        Image(systemName: "mappin")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(actionBlue)
                            .frame(width: 22, height: 22)
                    }
                    .buttonStyle(.plain)

                    TextField("Enter an address, neighbourhood or city", text: $query)
                        .font(.subheadline)
                        .foregroundStyle(.primary)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color(.systemGray6).opacity(0.9))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.black.opacity(0.06), lineWidth: 1)
                        )
                )
                Button(action: onSearch) {
                    Text("Search")
                        .font(.headline.weight(.semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                }
                .background(
                    RoundedRectangle(cornerRadius: 25, style: .continuous)
                        .fill(actionBlue)
                )
                .buttonStyle(.plain)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 8)
            )

            
        }
    }
}

#Preview("FloodSearchCard") {
    @Previewable @State var q = ""

    return FloodSearchCard(
        query: $q,
        onPinTap: { print("Pin tapped") },
        onSearch: { print("Search tapped: \(q)") }
    )
    .padding()
    .background(Color(.systemBackground))
}
