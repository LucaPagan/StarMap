//
//  AstroCalculator.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import Foundation
import CoreLocation

/// Provides astronomical calculations for coordinate system conversions.
struct AstroCalculator {
    
    // MARK: - Equatorial to Horizontal Conversion
    
    /// Converts equatorial coordinates (RA/Dec) to horizontal coordinates (Azimuth/Altitude)
    /// based on the observer's location and the current time.
    /// - Parameters:
    ///   - ra: Right Ascension in degrees (0-360)
    ///   - dec: Declination in degrees (-90 to +90)
    ///   - location: The observer's location (latitude/longitude)
    ///   - date: The current date and time
    /// - Returns: A tuple containing the azimuth and altitude in radians.
    static func equatorialToHorizontal(
        ra: Double,
        dec: Double,
        for location: CLLocation,
        at date: Date
    ) -> (azimuth: Double, altitude: Double) {
        
        let latitudeRad = location.coordinate.latitude.toRadians
        let longitudeRad = location.coordinate.longitude.toRadians
        
        // Calculate Local Sidereal Time (LST)
        let lstRad = calculateLocalSiderealTime(longitude: longitudeRad, date: date)
        
        let raRad = ra.toRadians
        let decRad = dec.toRadians
        
        // Calculate the Hour Angle
        let hourAngleRad = lstRad - raRad
        
        // Calculate altitude
        let sinAltitude = sin(decRad) * sin(latitudeRad) + cos(decRad) * cos(latitudeRad) * cos(hourAngleRad)
        let altitude = asin(sinAltitude)
        
        // Calculate azimuth
        let cosAzimuth = (sin(decRad) - sin(altitude) * sin(latitudeRad)) / (cos(altitude) * cos(latitudeRad))
        let sinAzimuth = -cos(decRad) * sin(hourAngleRad) / cos(altitude)
        
        var azimuth = atan2(sinAzimuth, cosAzimuth)
        
        // Normalize azimuth to the range [0, 2π]
        if azimuth < 0 {
            azimuth += 2 * .pi
        }
        
        return (azimuth: azimuth, altitude: altitude)
    }
    
    // MARK: - Horizontal to Cartesian Conversion
    
    /// Converts horizontal coordinates (Azimuth/Altitude) to 3D Cartesian coordinates for rendering.
    /// This defines the app's rendering coordinate system:
    /// - Y-axis points to the Zenith (straight up).
    /// - X/Z-plane is the horizon.
    /// - Negative Z-axis points North.
    /// - Negative X-axis points East.
    static func horizontalToCartesian(azimuth: Double, altitude: Double) -> CartesianCoordinates {
        // ℹ️ NOTA: Questa è la conversione corretta per allineare i pianeti
        // con l'orizzonte e i punti cardinali definiti nell'app.
        let y = sin(altitude)                     // Vertical component: up/down
        let r = cos(altitude)                     // Radius on the horizontal plane
        let x = -r * sin(azimuth)                 // East (-)/West (+) component
        let z = -r * cos(azimuth)                 // North (-)/South (+) component
        
        return CartesianCoordinates(x: x, y: y, z: z)
    }

    // MARK: - Local Sidereal Time Calculation
    
    /// Calculates the Local Sidereal Time for a given location and time.
    private static func calculateLocalSiderealTime(longitude: Double, date: Date) -> Double {
        let jd = date.julianDay
        let T = (jd - 2451545.0) / 36525.0 // Julian centuries since J2000.0
        
        // Calculate Greenwich Mean Sidereal Time (GMST) in degrees
        var gmst = 280.46061837 +
                   360.98564736629 * (jd - 2451545.0) +
                   0.000387933 * T * T -
                   T * T * T / 38710000.0
        
        // Use the extension to normalize GMST to [0, 360)
        gmst = gmst.normalizedDegrees
        
        let gmstRadians = gmst.toRadians
        
        // Local Sidereal Time is GMST plus the observer's longitude
        let lst = gmstRadians + longitude
        
        return lst
    }
}
