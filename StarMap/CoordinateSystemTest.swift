//
//  CoordinateSystemTest.swift
//  StarMap
//
//  Created by Luca Pagano on 13/10/25.
//

import Foundation
import SwiftUI
import SwissEphemeris

/// Temporary diagnostic tool to verify coordinate alignment
struct CoordinateSystemTest {
    
    /// Test known celestial objects to verify coordinate transformation
    static func runDiagnostics() {
        print("\n🔍 === COORDINATE SYSTEM DIAGNOSTICS ===")
        
        testStar(name: "Polaris", ra: 37.95, dec: 89.26)
        testStar(name: "Sirius", ra: 101.29, dec: -16.72)
        
        print("\n=== END DIAGNOSTICS ===\n")
    }
    
    private static func testStar(name: String, ra: Double, dec: Double) {
        // 👈 FIX: La funzione è ora qui dentro, non più in AstroCalculator.
        let cartesian = equatorialToCartesian(ra: ra, dec: dec)
        
        // Apply rotation
        let rotationAngle = Double.pi / 2
        let rotatedY = cartesian.y * cos(rotationAngle) - cartesian.z * sin(rotationAngle)
        let rotatedZ = cartesian.y * sin(rotationAngle) + cartesian.z * cos(rotationAngle)
        let rotated = CartesianCoordinates(x: cartesian.x, y: rotatedY, z: rotatedZ)
        
        // Apply specular inversion
        let final = CartesianCoordinates(x: -rotated.x, y: rotated.y, z: rotated.z)
        
        print("\n⭐️ \(name):")
        print("  Input: RA=\(String(format: "%.2f", ra))° Dec=\(String(format: "%.2f", dec))°")
        print("  Final: x=\(String(format: "%.3f", final.x)), y=\(String(format: "%.3f", final.y)), z=\(String(format: "%.3f", final.z))")
    }

    /// Converts equatorial coordinates to Cartesian coordinates.
    /// This logic was moved from AstroCalculator.
    private static func equatorialToCartesian(ra: Double, dec: Double) -> CartesianCoordinates {
        let raRad = ra.toRadians
        let decRad = dec.toRadians
        
        let x = cos(decRad) * cos(raRad)
        let y = cos(decRad) * sin(raRad)
        let z = sin(decRad)
        
        return CartesianCoordinates(x: x, y: y, z: z)
    }
}
