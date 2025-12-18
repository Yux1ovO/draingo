//
//  MapScreen.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    private let api = APIClient(baseURL: URL(string: "https://YOUR_BACKEND_DOMAIN")!)

    @State private var camera: MapCameraPosition = .automatic
    @State private var nodes: [FloodNode] = []
    @State private var selected: FloodNode?

    var body: some View {
        Map(position: $camera) {
            ForEach(nodes) { node in
                Annotation("", coordinate: node.coordinate) {
                    Text("\(node.riskLevel)")
                        .font(.caption.bold())
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(.blue))
                        .foregroundStyle(.white)
                        .onTapGesture { selected = node }
                }
            }
        }
        .onMapCameraChange(frequency: .onEnd) { ctx in
            let bbox = bbox(from: ctx.region)
            Task {
                // (Optional) add debounce later — start simple
                do { nodes = try await api.fetchNodes(bbox: bbox) }
                catch { /* show an alert later */ }
            }
        }
        .sheet(item: $selected) { node in
            VStack(alignment: .leading, spacing: 8) {
                Text("Risk \(node.riskLevel)").font(.title2.bold())
                if let d = node.depthCm { Text("Depth: \(d, specifier: "%.1f") cm") }
                Text("Updated: \(node.updatedAt.formatted())").foregroundStyle(.secondary)
            }
            .padding()
            .presentationDetents([.medium])
        }
    }

    private func bbox(from region: MKCoordinateRegion) -> BoundingBox {
        let halfLat = region.span.latitudeDelta / 2
        let halfLng = region.span.longitudeDelta / 2
        return .init(
            minLat: region.center.latitude - halfLat,
            minLng: region.center.longitude - halfLng,
            maxLat: region.center.latitude + halfLat,
            maxLng: region.center.longitude + halfLng
        )
    }
}

#Preview {
    MapScreen()
}
