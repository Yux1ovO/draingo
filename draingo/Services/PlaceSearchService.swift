//
//  PlaceSearchService.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import Foundation
import MapKit
import CoreLocation

final class PlaceSearchService {

    func search(query: String, near region: MKCoordinateRegion?) async throws -> MKMapItem? {
        let req = MKLocalSearch.Request()
        req.naturalLanguageQuery = query
        if let region { req.region = region }

        let search = MKLocalSearch(request: req)
        let resp = try await search.start()
        return resp.mapItems.first
    }

    func reverseGeocode(lat: Double, lng: Double) async -> String? {
        let location = CLLocation(latitude: lat, longitude: lng)

        do {
            let request = MKReverseGeocodingRequest(location: location)
            let items = try await request?.mapItems
            guard let item = items?.first else { return nil }

            if let reps = item.addressRepresentations {
                if let city = reps.cityName { return city }
                if let cityCtx = reps.cityWithContext { return cityCtx }
                if let full = reps.fullAddress(includingRegion: false, singleLine: true) {
                    return full
                }
                if let region = reps.regionName { return region }
            }

            // Fallback (often POI/area name)
            return item.name
        } catch {
            return nil
        }
    }
}

extension MKMapItem {
    /// iOS 26+ friendly: avoids placemark.*
    func displayNameForUI() -> String? {
        if let reps = self.addressRepresentations {
            if let city = reps.cityName { return city } //  [oai_citation:2‡MKAddressRepresentations | Apple Developer Documentation.pdf](sediment://file_00000000ad4c7206a8c40545e8d69bd6)
            if let full = reps.fullAddress(includingRegion: false, singleLine: true) {
                return full //  [oai_citation:3‡MKAddressRepresentations | Apple Developer Documentation.pdf](sediment://file_00000000ad4c7206a8c40545e8d69bd6)
            }
            if let region = reps.regionName { return region } //  [oai_citation:4‡MKAddressRepresentations | Apple Developer Documentation.pdf](sediment://file_00000000ad4c7206a8c40545e8d69bd6)
        }
        return self.name
    }
}
