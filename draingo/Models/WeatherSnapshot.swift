//
//  WeatherSnapshot.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import Foundation

struct WeatherSnapshot: Equatable {
    let time: Date
    let temperatureC: Double
    let windSpeedKmh: Double
    let precipitationMm: Double
    let weatherCode: Int
    let isDay: Bool

    var riskIndex: Int {
        var score = 0
        if windSpeedKmh >= 40 { score += 2 }
        else if windSpeedKmh >= 25 { score += 1 }

        if precipitationMm >= 5 { score += 2 }
        else if precipitationMm >= 1 { score += 1 }

        // Weather codes for heavier precipitation / storms
        if [65, 66, 67, 80, 81, 82, 95, 96, 99].contains(weatherCode) { score += 1 }

        return min(5, score)
    }

    var conditionText: String {
        WeatherCode.describe(code: weatherCode)
    }

    var iconName: String {
        WeatherCode.sfSymbol(code: weatherCode, isDay: isDay)
    }
}
