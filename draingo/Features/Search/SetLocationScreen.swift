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

    var body: some View {
        ZStack {
            Map(position: $camera) {
                // optional: show a marker at center
                Annotation("", coordinate: vm.region.center) {}
            }
            .onMapCameraChange(frequency: .onEnd) { ctx in
                vm.onMapRegionChange(ctx.region)
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
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }

    private func performSearchAndFocus() {
        Task {
            if let newRegion = await vm.searchTapped() {
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
}

#Preview("SetLocationScreen") {
    SetLocationScreen()
}
