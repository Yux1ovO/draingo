//
//  NodeReportViewModel.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-21.
//

import Foundation
import Observation
import PhotosUI
import UIKit
import _PhotosUI_SwiftUI

@Observable
final class NodeReportViewModel {
    var message: String = ""
    var selectedItem: PhotosPickerItem?
    var selectedImage: UIImage?
    var isSubmitting: Bool = false
    var errorMessage: String?

    private(set) var imageData: Data?
    private let node: FloodNode
    private let reportService: FloodReportService

    init(node: FloodNode, reportService: FloodReportService = FloodReportService()) {
        self.node = node
        self.reportService = reportService
    }

    var canSubmit: Bool {
        !message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isSubmitting
    }

    @MainActor
    func loadImage(from item: PhotosPickerItem?) async {
        guard let item else { return }

        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let image = UIImage(data: data),
               let jpegData = image.jpegData(compressionQuality: 0.8) {
                selectedImage = image
                imageData = jpegData
            }
        } catch {
            errorMessage = "Unable to load the selected photo."
        }
    }

    @MainActor
    func submit() async -> Bool {
        guard canSubmit else { return false }

        isSubmitting = true
        defer { isSubmitting = false }
        errorMessage = nil

        do {
            try await reportService.createReport(
                nodeId: node.id,
                message: message,
                imageData: imageData
            )
            return true
        } catch {
            errorMessage = "Unable to submit report."
            return false
        }
    }
}
