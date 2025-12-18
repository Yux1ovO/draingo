//
//  OpenMeteoForecastResponse.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import Foundation

struct OpenMeteoForecastResponse: Decodable {
    struct Current: Decodable {
        let time: String
        let temperature_2m: Double
        let wind_speed_10m: Double
        let precipitation: Double
        let weather_code: Int
        let is_day: Int
    }

    let current: Current
}
