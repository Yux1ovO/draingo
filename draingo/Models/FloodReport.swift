//
//  FloodReport.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-20.
//

import Foundation

struct FloodReport: Identifiable, Decodable, Equatable {
    let id: String
    let nodeId: String
    let message: String
    let imageUrl: String?
    let createdAt: Date

    private enum CodingKeys: String, CodingKey {
        case id
        case nodeId = "node_id"
        case message
        case imageUrl = "image_url"
        case createdAt = "created_at"
    }
}
