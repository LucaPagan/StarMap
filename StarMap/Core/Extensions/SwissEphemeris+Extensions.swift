//
//  SwissEphemerisUtils.swift
//  StarMap
//
//  Created by Luca Pagano on 10/12/25.
//

import Foundation
import SwissEphemeris
import CSwissEphemeris

/// A utility enum for interacting with the Swiss Ephemeris C library.
enum SwissEphemerisUtils {
    
    /// Fetches the Equatorial coordinates (Right Ascension/Declination) for a celestial body at a specific date.
    /// - Returns: A tuple containing RA and Dec in degrees, or nil on failure.
    static func getEquatorialCoordinates(for planet: SwissEphemeris.Planet, at date: Date) -> (ra: Double, dec: Double)? {
        let julianDay = date.julianDay
        var position = [Double](repeating: 0.0, count: 6)
        var error = [CChar](repeating: 0, count: 256)
        
        // Use ICRS/J2000 equatorial coordinates for consistency with star catalog
        // IMPORTANT: Most star catalogs use J2000.0 coordinates
        let flags = SEFLG_SWIEPH | SEFLG_EQUATORIAL | SEFLG_J2000
        let result = swe_calc_ut(
            julianDay,
            Int32(planet.rawValue),
            flags,
            &position,
            &error
        )
        
        if result < 0 {
            let errorMessage = String(cString: error)
            print("❌ Swiss Ephemeris Error for \(String(describing: planet)): \(errorMessage)")
            return nil
        }
        
        // RA is position[0], Dec is position[1]
        let ra = position[0]
        let dec = position[1]
        
        print("  📍 SwissEph: \(String(describing: planet)) JD=\(String(format: "%.2f", julianDay)) → RA=\(String(format: "%.4f", ra))° Dec=\(String(format: "%.4f", dec))°")
        
        return (ra: ra, dec: dec)
    }
}
