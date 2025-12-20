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
}
