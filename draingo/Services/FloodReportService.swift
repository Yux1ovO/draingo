//
//  FloodReportService.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-20.
//

import Foundation
import Supabase

struct FloodReportService {
    func fetchReports(nodeId: String) async throws -> [FloodReport] {
        try await supabase
            .from("flood_reports")
            .select()
            .eq("node_id", value: nodeId)
            .order("created_at", ascending: false)
            .limit(3)
            .execute()
            .value
    }

    func createReport(nodeId: String, message: String, imageData: Data?) async throws {
        let trimmedMessage = message.trimmingCharacters(in: .whitespacesAndNewlines)
        var imageUrl: String?

        if let imageData {
            let path = "public/\(nodeId)/\(UUID().uuidString).jpg"
            try await supabase.storage
                .from("flood-reports")
                .upload(
                    path,
                    data: imageData,
                    options: FileOptions(contentType: "image/jpeg", upsert: false)
                )
            imageUrl = try supabase.storage
                .from("flood-reports")
                .getPublicURL(path: path)
                .absoluteString
        }

        struct NewReport: Encodable {
            let nodeId: String
            let message: String
            let imageUrl: String?

            enum CodingKeys: String, CodingKey {
                case nodeId = "node_id"
                case message
                case imageUrl = "image_url"
            }
        }

        let payload = NewReport(nodeId: nodeId, message: trimmedMessage, imageUrl: imageUrl)

        try await supabase
            .from("flood_reports")
            .insert(payload)
            .execute()
    }
}
