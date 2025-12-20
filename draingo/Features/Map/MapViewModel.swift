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
    var currentRegion: MKCoordinateRegion?

    private let nodeService: FloodNodeService
    private var lastBBox: BoundingBox?
    private var refreshTask: Task<Void, Never>?

    init(nodeService: FloodNodeService = FloodNodeService()) {
        self.nodeService = nodeService
    }

    @MainActor
    func refreshNodes(for region: MKCoordinateRegion, force: Bool = false) async {
        currentRegion = region
        let bbox = BoundingBox(
            minLat: region.center.latitude - region.span.latitudeDelta / 2,
            minLng: region.center.longitude - region.span.longitudeDelta / 2,
            maxLat: region.center.latitude + region.span.latitudeDelta / 2,
            maxLng: region.center.longitude + region.span.longitudeDelta / 2
        )

        guard force || bbox != lastBBox else { return }
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

    @MainActor
    func updateRegion(_ region: MKCoordinateRegion) {
        currentRegion = region
    }

    @MainActor
    func startAutoRefresh(interval: TimeInterval) {
        stopAutoRefresh()
        refreshTask = Task {
            while !Task.isCancelled {
                if let region = currentRegion {
                    await refreshNodes(for: region, force: true)
                }
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }

    @MainActor
    func stopAutoRefresh() {
        refreshTask?.cancel()
        refreshTask = nil
    }

    deinit {
        refreshTask?.cancel()
    }
}
