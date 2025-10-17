//
//  ObjectDetailPopup.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import SwiftUI
import CoreLocation

/// A popup view that displays detailed information for a selected celestial object.
struct ObjectDetailPopup: View {
    let object: any CelestialObject
    @Binding var isPresented: Bool
    let userLocation: CLLocation?
    
    var body: some View {
        ZStack {
            // Dimming background that can be tapped to dismiss.
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { isPresented = false }
            
            VStack(spacing: 16) {
                headerView
                Divider().background(Color.white.opacity(0.3))
                infoRows
            }
            .padding(Constants.UI.popupPadding)
            .background(
                RoundedRectangle(cornerRadius: Constants.UI.popupCornerRadius)
                    .fill(.ultraThinMaterial)
                    .shadow(color: .black.opacity(0.3), radius: 20)
            )
            .padding(40)
        }
    }
    
    private var headerView: some View {
        HStack {
            Circle()
                .fill(object.primaryColor)
                .frame(width: 30, height: 30)
                .shadow(color: object.primaryColor.opacity(0.5), radius: 10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(object.name).font(.headline).foregroundColor(.white)
                Text(object.typeName).font(.caption).foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }
    
    private var infoRows: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(object.details.sorted(by: <), id: \.key) { key, value in
                InfoRow(icon: icon(for: key), label: key, value: value)
            }
            
            if let location = userLocation {
                InfoRow(
                    icon: "location.fill",
                    label: "Observed From",
                    value: "\(String(format: "%.2f", location.coordinate.latitude))°, \(String(format: "%.2f", location.coordinate.longitude))°"
                )
            }
        }
    }
    
    /// Returns a system icon name based on the detail's key.
    private func icon(for key: String) -> String {
        switch key {
        case "Spectral Class": return "thermometer.medium"
        case "Brightness": return "star.fill"
        case "Distance from Earth": return "arrow.left.and.right.circle"
        default: return "info.circle"
        }
    }
}
