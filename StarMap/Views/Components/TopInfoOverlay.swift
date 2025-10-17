//
//  TopInfoOverlay.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import SwiftUI
import CoreLocation

/// The top overlay view displaying tracking status, location, and compass information.
struct TopInfoOverlay: View {
    let isTracking: Bool
    let location: CLLocation?
    let compassHeading: Double
    let fieldOfView: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            trackingStatusView
            locationView
            compassView
            zoomView
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial.opacity(Constants.UI.overlayOpacity))
    }
    
    private var trackingStatusView: some View {
        Group {
            if isTracking {
                HStack(spacing: 6) {
                    Circle().fill(Constants.Colors.trackingIndicator).frame(width: Constants.UI.trackingIndicatorSize)
                    Text("Tracking Active").font(.headline).foregroundColor(.white)
                }
            } else {
                Text("Manual Exploration").font(.headline).foregroundColor(.white)
            }
        }
    }
    
    private var locationView: some View {
        Group {
            if let location = location {
                Text("📍 \(String(format: "%.2f", location.coordinate.latitude))°, \(String(format: "%.2f", location.coordinate.longitude))°")
            } else {
                Text("📍 Acquiring position...")
            }
        }
        .font(.caption).foregroundColor(.white.opacity(0.7))
    }
    
    private var compassView: some View {
        Text("🧭 Direction: \(String(format: "%.0f", compassHeading))° (\(compassHeading.cardinalDirectionName))")
            .font(.caption)
            .foregroundColor(Constants.Colors.compassText)
    }
    
    private var zoomView: some View {
        let zoomPercentage = (AppConfig.maximumFieldOfView / fieldOfView) * 100
        return Text("🔍 Zoom: \(String(format: "%.0f", zoomPercentage))%")
            .font(.caption2).foregroundColor(.white.opacity(0.7))
    }
}
