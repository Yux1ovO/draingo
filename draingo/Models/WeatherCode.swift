//
//  WeatherCode.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import Foundation

enum WeatherCode {
    static func describe(code: Int) -> String {
        switch code {
        case 0: return "Clear"
        case 1,2: return "Mainly clear"
        case 3: return "Overcast"
        case 45,48: return "Fog"
        case 51,53,55: return "Drizzle"
        case 56,57: return "Freezing drizzle"
        case 61,63: return "Rain"
        case 65: return "Heavy rain"
        case 66,67: return "Freezing rain"
        case 71,73: return "Snow"
        case 75: return "Heavy snow"
        case 77: return "Snow grains"
        case 80,81,82: return "Rain showers"
        case 95: return "Thunderstorm"
        case 96,99: return "Thunderstorm (hail)"
        default: return "Unknown"
        }
    }

    static func sfSymbol(code: Int, isDay: Bool) -> String {
        // Minimal mapping for now
        switch code {
        case 0: return isDay ? "sun.max.fill" : "moon.stars.fill"
        case 1,2,3: return "cloud.sun.fill"
        case 45,48: return "cloud.fog.fill"
        case 51,53,55,56,57: return "cloud.drizzle.fill"
        case 61,63,65,80,81,82: return "cloud.rain.fill"
        case 71,73,75,77: return "cloud.snow.fill"
        case 95,96,99: return "cloud.bolt.rain.fill"
        default: return "cloud.fill"
        }
    }
}
