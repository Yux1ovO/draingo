//
//  FloodNodeService.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-20.
//

import Foundation
import Supabase

struct FloodNodeService {
    func fetchNodes(bbox: BoundingBox) async throws -> [FloodNode] {
        try await supabase
            .from("flood_nodes_public")
            .select()
            .gte("lat", value: bbox.minLat)
            .lte("lat", value: bbox.maxLat)
            .gte("lng", value: bbox.minLng)
            .lte("lng", value: bbox.maxLng)
            .order("updated_at", ascending: false)
            .execute()
            .value
    }
}
