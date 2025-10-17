//
//  Nebula.swift
//  StarMap
//
//  Created on 16/10/25.
//

import SwiftUI

/// A model representing a nebula, galaxy, or star cluster.
struct Nebula: CelestialObject {
    let id = UUID()  // Required by CelestialObject protocol
    let catalogId: String  // Catalog ID (e.g., "M1", "M42")
    let name: String
    
    /// The nebula's 3D Cartesian position, calculated based on user location.
    var position: CartesianCoordinates
    
    /// The nebula's raw equatorial coordinates.
    let ra: Double  // Right Ascension in degrees
    let dec: Double // Declination in degrees
    
    // Visual properties
    let magnitude: Double
    let primaryColor: Color
    let size: Float
    let spectralClass: String
    
    // MARK: - CelestialObject Conformance
    
    var typeName: String { "Nebula" }
    
    var details: [String: String] {
        return [
            "Catalog ID": catalogId,
            "Magnitude": String(format: "%.1f", magnitude),
            "Spectral Type": spectralClass
        ]
    }
}
