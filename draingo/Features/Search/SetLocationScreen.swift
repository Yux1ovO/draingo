//
//  SetLocationScreen.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import SwiftUI
import MapKit

struct SetLocationScreen: View {
    @State private var vm = SetLocationViewModel()
    @State private var camera: MapCameraPosition = .automatic
    @State private var pendingRegion: MKCoordinateRegion?
    @State private var mapViewModel = MapViewModel()
    @State private var viewState: ViewState = .search

    private enum ViewState {
        case search
        case results
    }

    var body: some View {
        ZStack {
            Map(position: $camera) {
                if viewState == .results {
                    ForEach(mapViewModel.nodes) { node in
                        Annotation("", coordinate: node.coordinate) {
                            RiskNodeAnnotation(node: node)
                                .onTapGesture { mapViewModel.selectedNode = node }
                        }
                    }
                }
            }
            .onMapCameraChange(frequency: .onEnd) { ctx in
                mapViewModel.updateRegion(ctx.region)
                vm.onMapRegionChange(ctx.region)
                if let pending = pendingRegion, isRegion(ctx.region, closeTo: pending) {
                    viewState = .results
                    pendingRegion = nil
                    Task { await mapViewModel.refreshNodes(for: ctx.region, force: true) }
                } else if viewState == .results {
                    Task { await mapViewModel.refreshNodes(for: ctx.region) }
                }
            }
            .ignoresSafeArea()

            if viewState == .results {
                CenterPinOverlay()
            }

            VStack(spacing: 0) {

                if viewState == .search {
                    WeatherCard(
                        placeName: vm.placeName,
                        weather: vm.weather,
                        isLoading: vm.isLoadingWeather
                    )
                    .padding(.horizontal, 16)

                    Spacer()

                    FloodSearchCard(
                        query: $vm.query,
                        onPinTap: { vm.useCenterAsLocation() },
                        onSearch: { performSearchAndFocus() }
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 18)
                }
            }

            if mapViewModel.isLoading && viewState == .results {
                VStack {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .padding(10)
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                    Spacer()
                }
                .padding(.top, 12)
            }

            if viewState == .results {
                VStack {
                    HStack {
                        Button {
                            viewState = .search
                            mapViewModel.selectedNode = nil
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "chevron.left")
                                    .font(.caption.weight(.semibold))
                                Text("Back")
                                    .font(.subheadline.weight(.semibold))
                            }
                            .foregroundStyle(.primary)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(.ultraThinMaterial, in: Capsule())
                            .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    Spacer()
                }
                .padding(.leading, 16)
                .padding(.top, 10)
            }
        }
        .onAppear {
            vm.onAppear()
            moveCamera(to: vm.region, animated: false)
            mapViewModel.updateRegion(vm.region)
        }
        .onDisappear {
            mapViewModel.stopAutoRefresh()
        }
        .onChange(of: viewState) { _, newValue in
            if newValue == .results {
                mapViewModel.startAutoRefresh(interval: 2.5)
            } else {
                mapViewModel.stopAutoRefresh()
            }
        }
        .navigationTitle("Set Location")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil || mapViewModel.errorMessage != nil },
            set: { _ in
                vm.errorMessage = nil
                mapViewModel.errorMessage = nil
            }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? mapViewModel.errorMessage ?? "")
        }
        .sheet(item: $mapViewModel.selectedNode) { node in
            NodeDetailSheet(node: node)
                .presentationDetents([.medium])
        }
    }

    private func performSearchAndFocus() {
        Task {
            if let newRegion = await vm.searchTapped() {
                viewState = .search
                if let currentRegion = mapViewModel.currentRegion, isRegion(currentRegion, closeTo: newRegion) {
                    pendingRegion = nil
                    viewState = .results
                    Task { await mapViewModel.refreshNodes(for: currentRegion, force: true) }
                } else {
                    pendingRegion = newRegion
                    moveCamera(to: newRegion)
                }
            }
        }
    }

    @MainActor
    private func moveCamera(to region: MKCoordinateRegion, animated: Bool = true) {
        let position = MapCameraPosition.region(region)
        if animated {
            withAnimation(.easeInOut) { camera = position }
        } else {
            camera = position
        }
    }

    private func isRegion(_ lhs: MKCoordinateRegion, closeTo rhs: MKCoordinateRegion) -> Bool {
        let latDelta = abs(lhs.center.latitude - rhs.center.latitude)
        let lngDelta = abs(lhs.center.longitude - rhs.center.longitude)
        return latDelta < 0.0005 && lngDelta < 0.0005
    }
}

#Preview("SetLocationScreen") {
    SetLocationScreen()
}
