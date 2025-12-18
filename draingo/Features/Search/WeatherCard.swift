//
//  WeatherCard.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-19.
//

import SwiftUI

struct WeatherCard: View {
    let placeName: String
    let weather: WeatherSnapshot?
    let isLoading: Bool

    private var headerText: String {
        guard let w = weather else { return "—" }
        return w.time.formatted(.dateTime.hour(.defaultDigits(amPM: .abbreviated)).minute().day().month(.wide))
    }

    private var typhoonIndexText: String {
        "Typhoon Index: \(weather?.riskIndex ?? 0)"
    }

    private var cardBlue: Color {
        Color(red: 0.18, green: 0.36, blue: 0.93)
    }

    private var cardBlue2: Color {
        Color(red: 0.16, green: 0.30, blue: 0.86)
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [cardBlue, cardBlue2],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: .black.opacity(0.18), radius: 14, x: 0, y: 8)

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .center) {
                    Text(headerText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.90))
                }

                HStack(spacing: 10) {
                    Image(systemName: weather?.iconName ?? "cloud.fill")
                        .font(.title2.weight(.semibold))
                        .foregroundStyle(.white)

                    Text(placeName.uppercased())
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.white)

                    Spacer()

                    Text(typhoonIndexText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.90))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
        }
        .frame(height: 92)
    }
}

#Preview("WeatherCard – Loaded") {
    WeatherCard(
        placeName: "EDINBURGH",
        weather: WeatherSnapshot(
            time: Date(),
            temperatureC: 7,
            windSpeedKmh: 22,
            precipitationMm: 0.8,
            weatherCode: 61,
            isDay: true
        ),
        isLoading: false
    )
    .padding()
    .background(Color(.systemBackground))
}

#Preview("WeatherCard – Loading") {
    WeatherCard(
        placeName: "EDINBURGH",
        weather: nil,
        isLoading: true
    )
    .padding()
    .background(Color(.systemBackground))
}
