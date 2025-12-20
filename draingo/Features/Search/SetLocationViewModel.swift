//
//  SetLocationViewModel.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import Foundation
import MapKit
import Observation

@Observable
final class SetLocationViewModel {
    var query: String = ""
    var placeName: String = "EDINBURGH"
    var weather: WeatherSnapshot?
    var isLoadingWeather: Bool = false
    var isSearching: Bool = false
    var errorMessage: String?

    // Map state
    var region: MKCoordinateRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 55.9533, longitude: -3.1883),
        span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.03)
    )

    private let weatherService = WeatherService()
    private let placeSearch = PlaceSearchService()

    func onAppear() {
        Task { await refreshWeather() }
    }

    func onMapRegionChange(_ newRegion: MKCoordinateRegion) {
        let dLat = abs(region.center.latitude - newRegion.center.latitude)
        let dLng = abs(region.center.longitude - newRegion.center.longitude)        // optional: don’t fetch constantly while moving; only fetch on Search / pin tap
        guard dLat > 0.0001 || dLng > 0.0001 else { return }
        region = newRegion
    }

    func useCenterAsLocation() {
        Task { @MainActor in
            let name = await placeSearch.reverseGeocode(
                lat: region.center.latitude,
                lng: region.center.longitude
            )
            if let name { placeName = name.uppercased() }
            await refreshWeather()
        }
    }

    @MainActor
    func searchTapped() async -> MKCoordinateRegion? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        isSearching = true
        defer { isSearching = false }

        do {
            let item = try await placeSearch.search(query: trimmed, near: region)
            guard let item else { return nil }

            let coord = item.location.coordinate
            region.center = coord

            let label = item.displayNameForUI() ?? trimmed
            placeName = label.uppercased()
            Task { await refreshWeather() }
            return region
        } catch {
            errorMessage = "Search failed. Try a different query."
            return nil
        }
    }

    @MainActor
    func refreshWeather() async {
        isLoadingWeather = true
        errorMessage = nil
        do {
            let snapshot = try await weatherService.fetchCurrent(
                lat: region.center.latitude,
                lng: region.center.longitude
            )
            weather = snapshot
        } catch {
            errorMessage = "Failed to load weather."
        }
        isLoadingWeather = false
    }
}
