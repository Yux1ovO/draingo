//
//  FloodNode.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import Foundation
import CoreLocation

struct FloodNode: Identifiable, Decodable, Equatable {
    let id: String
    let lat: Double
    let lng: Double
    let riskLevel: Int
    let depthCm: Double?
    let updatedAt: Date

    var coordinate: CLLocationCoordinate2D {
        .init(latitude: lat, longitude: lng)
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case lat
        case lng
        case riskLevel = "risk_level"
        case depthCm = "depth_cm"
        case updatedAt = "updated_at"
    }
}
