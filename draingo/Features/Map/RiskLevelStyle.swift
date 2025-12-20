//
//  RiskLevelStyle.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-20.
//

import SwiftUI

struct RiskPalette {
    let outer: Color
    let inner: Color
    let stroke: Color
    let text: Color
}

enum RiskLevelStyle {
    static let accent = Color(red: 0.28, green: 0.32, blue: 0.90)

    static func palette(for riskLevel: Int) -> RiskPalette {
        switch riskLevel {
        case ...2:
            return RiskPalette(
                outer: Color(red: 0.40, green: 0.70, blue: 0.95, opacity: 0.35),
                inner: Color(red: 0.74, green: 0.90, blue: 0.98),
                stroke: Color(red: 0.35, green: 0.62, blue: 0.86),
                text: Color(red: 0.18, green: 0.40, blue: 0.63)
            )
        case 3...5:
            return RiskPalette(
                outer: Color(red: 0.46, green: 0.47, blue: 0.95, opacity: 0.35),
                inner: Color(red: 0.99, green: 0.83, blue: 0.32),
                stroke: Color(red: 0.91, green: 0.72, blue: 0.20),
                text: Color(red: 0.56, green: 0.42, blue: 0.06)
            )
        default:
            return RiskPalette(
                outer: Color(red: 0.74, green: 0.30, blue: 0.42, opacity: 0.35),
                inner: Color(red: 0.96, green: 0.60, blue: 0.56),
                stroke: Color(red: 0.79, green: 0.28, blue: 0.35),
                text: Color(red: 0.44, green: 0.16, blue: 0.22)
            )
        }
    }

    static func label(for riskLevel: Int) -> String {
        switch riskLevel {
        case ...2:
            return "Low"
        case 3...5:
            return "Moderate"
        case 6...7:
            return "High"
        default:
            return "Severe"
        }
    }

    static func guidance(for riskLevel: Int) -> String {
        switch riskLevel {
        case ...2:
            return "Shallow pooling possible. Walk normally but watch for uneven pavement."
        case 3...5:
            return "Above the ankle and close to the lower shin for most adults. Best to slow down and walk along the edge."
        case 6...7:
            return "Around knee level in spots. Avoid if possible and use elevated paths."
        default:
            return "Severe depth and flow. Do not enter. Find an alternate route."
        }
    }

    static func badgeFill(for riskLevel: Int) -> Color {
        palette(for: riskLevel).inner
    }

    static func depthColor(for riskLevel: Int) -> Color {
        switch riskLevel {
        case ...2:
            return Color(red: 0.20, green: 0.50, blue: 0.80)
        case 3...5:
            return Color(red: 0.88, green: 0.58, blue: 0.18)
        default:
            return Color(red: 0.78, green: 0.26, blue: 0.30)
        }
    }
}
