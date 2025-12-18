//
//  WeatherSnapshotTests.swift
//  draingoTests
//
//  Created by Codex on 2025-12-20.
//

import Foundation
import Testing
@testable import draingo

struct WeatherSnapshotTests {

    @Test func capsRiskIndexAtFive() async throws {
        let snapshot = WeatherSnapshot(
            time: Date(),
            temperatureC: 11.5,
            windSpeedKmh: 42,          // +2
            precipitationMm: 6.2,      // +2
            weatherCode: 81,           // +1
            isDay: true
        )

        #expect(snapshot.riskIndex == 5)
        #expect(snapshot.conditionText == "Rain showers")
        #expect(snapshot.iconName == "cloud.rain.fill")
    }

    @Test func clearNightHasZeroRisk() async throws {
        let snapshot = WeatherSnapshot(
            time: Date(),
            temperatureC: 18,
            windSpeedKmh: 5,
            precipitationMm: 0,
            weatherCode: 0,
            isDay: false
        )

        #expect(snapshot.riskIndex == 0)
        #expect(snapshot.conditionText == "Clear")
        #expect(snapshot.iconName == "moon.stars.fill")
    }
}
