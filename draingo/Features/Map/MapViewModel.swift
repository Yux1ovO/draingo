//
//  MapViewModel.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import Foundation
import MapKit
import Observation

@Observable
final class MapViewModel {
    var nodes: [FloodNode] = []
    var selectedNode: FloodNode?
    var isLoading: Bool = false
    var errorMessage: String?

    private let nodeService: FloodNodeService
    private var lastBBox: BoundingBox?

    init(nodeService: FloodNodeService = FloodNodeService()) {
        self.nodeService = nodeService
    }

    @MainActor
    func refreshNodes(for region: MKCoordinateRegion) async {
        let bbox = BoundingBox(
            minLat: region.center.latitude - region.span.latitudeDelta / 2,
            minLng: region.center.longitude - region.span.longitudeDelta / 2,
            maxLat: region.center.latitude + region.span.latitudeDelta / 2,
            maxLng: region.center.longitude + region.span.longitudeDelta / 2
        )

        guard bbox != lastBBox else { return }
        lastBBox = bbox

        errorMessage = nil
        isLoading = true
        defer { isLoading = false }

        do {
            nodes = try await nodeService.fetchNodes(bbox: bbox)
        } catch {
            errorMessage = "Failed to load flood nodes."
        }
    }
}
