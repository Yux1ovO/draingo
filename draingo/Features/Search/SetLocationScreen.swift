//
//  SetLocationScreen.swift
//  draingo
//
//  Created by Zhixing Wang on 2025-12-19.
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
                Annotation("", coordinate: vm.region.center) {
                    Circle()
                        .fill(Color.blue.opacity(0.25))
                        .frame(width: 46, height: 46)
                        .overlay(Circle().stroke(.white.opacity(0.8), lineWidth: 2))
                }
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
                    onSearch: { vm.searchTapped() }
                )
                .padding(.horizontal, 16)
                .padding(.bottom, 18)
            }
        }
        .onAppear { vm.onAppear() }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { _ in vm.errorMessage = nil }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}

#Preview("SetLocationScreen") {
    SetLocationScreen()
}
