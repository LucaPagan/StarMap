//
//  PlanetProvider.swift
//  StarMap
//
//  Created by Luca Pagano on 10/12/25.
//

import Foundation
import SwiftUI
import SwissEphemeris

/// Provides initial data and celestial coordinates for the planets.
enum PlanetProvider {
    
    private static let solarSystemBodies: [(body: SwissEphemeris.Planet, name: String, color: Color, size: Float)] = [
        (.sun, "Sun", .yellow, 12),
        (.moon, "Moon", .gray, 10),
        (.mercury, "Mercury", Color(red: 0.7, green: 0.7, blue: 0.7), 5),
        (.venus, "Venus", .yellow.opacity(0.8), 7),
        (.mars, "Mars", .red, 6),
        (.jupiter, "Jupiter", .orange, 10),
        (.saturn, "Saturn", .yellow.opacity(0.6), 9),
        (.uranus, "Uranus", .cyan.opacity(0.7), 8),
        (.neptune, "Neptune", .blue, 8)
    ]
    
    /// Creates an array of `Planet` objects with their current equatorial coordinates for a specific date.
    static func createPlanetsForDate(_ date: Date) -> [Planet] {
        return solarSystemBodies.compactMap { item in
            // Fetch the current RA/Dec for the celestial body at the given date
            guard let coords = SwissEphemerisUtils.getEquatorialCoordinates(for: item.body, at: date) else {
                print("❌ Failed to calculate coordinates for \(item.name) at \(date)")
                return nil
            }
            
            // Create the Planet object with a placeholder position
            // The actual Cartesian position will be calculated by the ViewModel
            // using the same coordinate system as stars
            return Planet(
                name: item.name,
                body: item.body,
                position: CartesianCoordinates(x: 0, y: 0, z: 0),
                ra: coords.ra,
                dec: coords.dec,
                primaryColor: item.color,
                size: item.size
            )
        }
    }
    
    /// Legacy method for backward compatibility - uses current date
    @available(*, deprecated, message: "Use createPlanetsForDate(_:) instead")
    static func createPlanets() -> [Planet] {
        return createPlanetsForDate(Date())
    }
}
