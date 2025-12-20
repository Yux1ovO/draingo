//
//  NodeReportSheet.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-21.
//

import PhotosUI
import SwiftUI

struct NodeReportSheet: View {
    let node: FloodNode
    let onSubmit: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: NodeReportViewModel
    private let gradient = LinearGradient(
        colors: [
            Color(red: 0.31, green: 0.50, blue: 0.98),
            Color(red: 0.20, green: 0.37, blue: 0.82)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    init(node: FloodNode, onSubmit: @escaping () -> Void) {
        self.node = node
        self.onSubmit = onSubmit
        _viewModel = State(initialValue: NodeReportViewModel(node: node))
    }

    var body: some View {
        @Bindable var viewModel = viewModel

        ZStack {
            gradient.ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 18) {
                    Text("Reflection")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)

                    Text("Problem statement")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.9))

                    PlaceholderTextEditor(
                        text: $viewModel.message,
                        placeholder: "Please fill in the problem description."
                    )

                    PhotosPicker(selection: $viewModel.selectedItem, matching: .images) {
                        PhotoPickerTile(image: viewModel.selectedImage)
                    }

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.9))
                    }

                    Button {
                        Task {
                            if await viewModel.submit() {
                                onSubmit()
                                dismiss()
                            }
                        }
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isSubmitting {
                                ProgressView()
                            } else {
                                Text("Submit")
                                    .font(.headline.weight(.semibold))
                            }
                            Spacer()
                        }
                        .frame(height: 50)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.white)
                    .foregroundStyle(Color(red: 0.26, green: 0.36, blue: 0.88))
                    .disabled(!viewModel.canSubmit)
                    .opacity(viewModel.canSubmit ? 1 : 0.7)
                }
                .padding(20)
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        .onChange(of: viewModel.selectedItem) { _, newValue in
            Task { await viewModel.loadImage(from: newValue) }
        }
    }
}

private struct PlaceholderTextEditor: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .scrollContentBackground(.hidden)
                .padding(8)
                .frame(minHeight: 140)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

            if text.isEmpty {
                Text(placeholder)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 14)
            }
        }
    }
}

private struct PhotoPickerTile: View {
    let image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                Label("Add photo", systemImage: "camera")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 52)
        .padding(.horizontal, 12)
        .background(Color.white.opacity(0.98))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

#Preview {
    NodeReportSheet(
        node: FloodNode(
            id: "preview",
            name: "Gilmore Place",
            lat: 55.9533,
            lng: -3.1883,
            riskLevel: 5,
            depthCm: 12,
            updatedAt: Date()
        ),
        onSubmit: {}
    )
    .background(Color.gray.opacity(0.2))
}
