//
//  NodeDetailViewModel.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-20.
//

import Foundation
import Observation

@Observable
final class NodeDetailViewModel {
    var reports: [FloodReport] = []
    var addressLine: String = ""
    var isLoading: Bool = false
    var errorMessage: String?

    private let node: FloodNode
    private let reportService: FloodReportService
    private let placeSearchService: PlaceSearchService

    init(
        node: FloodNode,
        reportService: FloodReportService = FloodReportService(),
        placeSearchService: PlaceSearchService = PlaceSearchService()
    ) {
        self.node = node
        self.reportService = reportService
        self.placeSearchService = placeSearchService
    }

    @MainActor
    func load() async {
        isLoading = true
        defer { isLoading = false }
        errorMessage = nil

        async let reportsTask: [FloodReport] = try reportService.fetchReports(nodeId: node.id)
        async let addressTask: String? = placeSearchService.reverseGeocode(
            lat: node.lat,
            lng: node.lng
        )

        do {
            reports = try await reportsTask
        } catch {
            reports = []
            errorMessage = "Unable to load user reports."
        }
        addressLine = await addressTask ?? node.name ?? "Location unavailable"
    }
}
