//
//  APIClient.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import Foundation

struct BoundingBox: Equatable {
    let minLat: Double, minLng: Double, maxLat: Double, maxLng: Double
}

final class APIClient {
    let baseURL: URL
    init(baseURL: URL) { self.baseURL = baseURL }

    func fetchNodes(bbox: BoundingBox) async throws -> [FloodNode] {
        var c = URLComponents(url: baseURL.appendingPathComponent("/v1/nodes"),
                              resolvingAgainstBaseURL: false)!
        c.queryItems = [
            .init(name: "minLat", value: "\(bbox.minLat)"),
            .init(name: "minLng", value: "\(bbox.minLng)"),
            .init(name: "maxLat", value: "\(bbox.maxLat)"),
            .init(name: "maxLng", value: "\(bbox.maxLng)")
        ]

        var req = URLRequest(url: c.url!)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, _) = try await URLSession.shared.data(for: req)

        struct Response: Decodable { let nodes: [FloodNode] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(Response.self, from: data).nodes
    }
}
