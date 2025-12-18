//
//  WeatherServices.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import Foundation

final class WeatherService {
    enum WeatherError: Error { case badURL, badResponse }

    private let session: URLSession
    init(session: URLSession = .shared) { self.session = session }

    func fetchCurrent(lat: Double, lng: Double) async throws -> WeatherSnapshot {
        var c = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        c?.queryItems = [
            .init(name: "latitude", value: "\(lat)"),
            .init(name: "longitude", value: "\(lng)"),
            // Open-Meteo supports current=<vars> for current conditions  [oai_citation:2‡Open Meteo](https://open-meteo.com/en/docs)
            .init(name: "current", value: "temperature_2m,wind_speed_10m,precipitation,weather_code,is_day"),
            .init(name: "timezone", value: "auto")
        ]
        guard let url = c?.url else { throw WeatherError.badURL }

        let (data, resp) = try await session.data(from: url)
        guard let http = resp as? HTTPURLResponse, (200...299).contains(http.statusCode) else {
            throw WeatherError.badResponse
        }

        let decoded = try JSONDecoder().decode(OpenMeteoForecastResponse.self, from: data)

        // Open-Meteo returns ISO8601 time string in `current.time` when timezone is set  [oai_citation:3‡Open Meteo](https://open-meteo.com/en/docs)
        let date = ISO8601DateFormatter().date(from: decoded.current.time) ?? Date()

        return WeatherSnapshot(
            time: date,
            temperatureC: decoded.current.temperature_2m,
            windSpeedKmh: decoded.current.wind_speed_10m,
            precipitationMm: decoded.current.precipitation,
            weatherCode: decoded.current.weather_code,
            isDay: decoded.current.is_day == 1
        )
    }
}
