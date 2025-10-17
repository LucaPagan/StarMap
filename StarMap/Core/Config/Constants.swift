//
//  Constants.swift
//  StarMap
//
//  Created by Francesco Albano on 10/07/25.
//

import SwiftUI

/// Defines static UI constants and colors used throughout the application.
struct Constants {
    
    // MARK: - Colors
    struct Colors {
        static let skyGradientTop = Color(red: 0.0, green: 0.05, blue: 0.15)
        static let skyGradientBottom = Color.black
        static let horizonLine = Color.white.opacity(0.4)
        static let cardinalPoints = Color.yellow.opacity(0.7)
        static let trackingIndicator = Color.green
        static let compassText = Color.yellow.opacity(0.8)
    }
    
    // MARK: - UI Dimensions
    struct UI {
        static let trackingIndicatorSize: CGFloat = 8
        static let cardinalPointFontSize: CGFloat = 24
        static let horizonLineWidth: CGFloat = 2
        static let overlayOpacity: Double = 0.6
        static let popupPadding: CGFloat = 20
        static let popupCornerRadius: CGFloat = 20
    }
    
    // MARK: - Cardinal Directions
    static let cardinalDirections = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"]
}
