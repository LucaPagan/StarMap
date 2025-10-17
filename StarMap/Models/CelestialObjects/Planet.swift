//
//  Planet.swift
//  StarMap
//
//  Created by Francesco Albano on 10/12/25.
//

import SwiftUI
import SwissEphemeris

/// A model representing a planet or other solar system body.
struct Planet: CelestialObject {
    let id = UUID()
    let name: String
    let body: SwissEphemeris.Planet
    
    /// The planet's 3D Cartesian position, updated dynamically based on user location.
    var position: CartesianCoordinates
    
    /// The planet's raw equatorial coordinates, used for recalculation.
    let ra: Double  // Right Ascension in degrees
    let dec: Double // Declination in degrees
    
    // Visual properties
    let primaryColor: Color
    let size: Float
    
    // Dynamic properties populated by the ViewModel
    var distanceAU: Double = 0.0
    
    // MARK: - CelestialObject Conformance
    
    var typeName: String { "Planet" }
    
    var details: [String: String] {
        return [
            "Distance from Earth": "\(String(format: "%.2f", distanceAU)) AU"
        ]
    }
}
