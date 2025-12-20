//
//  CenterPinOverlay.swift
//  draingo
//
//  Created by Yuxi Shen on 2025-12-20.
//

import SwiftUI

struct CenterPinOverlay: View {
    var body: some View {
        GeometryReader { proxy in
            Image("center-pin")
                .resizable()
                .scaledToFit()
                .frame(width: 46, height: 32)
                .position(x: proxy.size.width / 2, y: proxy.size.height / 2 - 12)
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 4)
        }
        .allowsHitTesting(false)
    }
}

#Preview {
    CenterPinOverlay()
        .frame(width: 200, height: 200)
        .background(Color(.systemBackground))
}
