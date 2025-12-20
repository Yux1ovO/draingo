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
    @State private var mapDestination: MapDestination?

    private struct MapDestination: Identifiable, Hashable {
        let id = UUID()
        let region: MKCoordinateRegion

        static func == (lhs: MapDestination, rhs: MapDestination) -> Bool {
            lhs.id == rhs.id
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }

    var body: some View {
        ZStack {
            Map(position: $camera) {
                // optional: show a marker at center
                Annotation("", coordinate: vm.region.center) {}
            }
            .onMapCameraChange(frequency: .onEnd) { ctx in
                vm.onMapRegionChange(ctx.region)
                if let pending = pendingRegion, isRegion(ctx.region, closeTo: pending) {
                    mapDestination = MapDestination(region: pending)
                    pendingRegion = nil
                }
            }
            .ignoresSafeArea()

            VStack(spacing: 0) {

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
        .onAppear {
            vm.onAppear()
            moveCamera(to: vm.region, animated: false)
        }
        .navigationTitle("Set Location")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
        .navigationDestination(item: $mapDestination) { destination in
            MapScreen(region: destination.region)
        }
    }

    private func performSearchAndFocus() {
        Task {
            if let newRegion = await vm.searchTapped() {
                pendingRegion = newRegion
                moveCamera(to: newRegion)
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
