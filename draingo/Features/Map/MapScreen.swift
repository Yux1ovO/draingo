//
//  MapScreen.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import SwiftUI
import MapKit

struct MapScreen: View {
    @State private var camera: MapCameraPosition
    @State private var viewModel: MapViewModel
    private let startRegion: MKCoordinateRegion

    init(region: MKCoordinateRegion, viewModel: MapViewModel = MapViewModel()) {
        _camera = State(initialValue: .region(region))
        _viewModel = State(initialValue: viewModel)
        startRegion = region
    }

    var body: some View {
        ZStack {
            Map(position: $camera) {
                ForEach(viewModel.nodes) { node in
                    Annotation("", coordinate: node.coordinate) {
                        RiskNodeAnnotation(node: node)
                            .onTapGesture { viewModel.selectedNode = node }
                    }
                }
            }
            .onMapCameraChange(frequency: .onEnd) { ctx in
                Task { await viewModel.refreshNodes(for: ctx.region) }
            }
            .ignoresSafeArea()

            CenterPinOverlay()

            if viewModel.isLoading {
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    Spacer()
                }
                .padding(.top, 12)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { Task { await viewModel.refreshNodes(for: startRegion) } }
        .alert("Error", isPresented: Binding(
            get: { viewModel.errorMessage != nil },
            set: { _ in viewModel.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .sheet(item: $viewModel.selectedNode) { node in
            NodeDetailSheet(node: node)
                .presentationDetents([.medium])
        }
    }
}

#Preview {
    MapScreen(
        region: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 55.9533, longitude: -3.1883),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
        )
    )
}
