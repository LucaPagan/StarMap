import Foundation
import CoreLocation

// A data structure to decode star entries from the JSON file.
struct StarData: Codable {
    let id: String
    let ra: Double?   // Right Ascension
    let dec: Double?  // Declination
    let mag: Double   // Apparent Magnitude
    let name: String?
    let bv: Double?   // B-V color index
    let sp: String?   // Spectral type
}

/// A utility to load and parse star data from the bundled JSON file.
class StarDataLoader {
    
    // Cache del JSON decodificato per evitare di rileggerlo ogni volta
    private static var cachedStarData: [StarData]?
    
    /// Loads raw star data from JSON and caches it for reuse.
    private static func loadRawStarData(maxMagnitude: Double = 6.5) -> [StarData] {
        if let cached = cachedStarData {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "stars_compact", withExtension: "json") else {
            fatalError("❌ Critical error: stars_compact.json not found in bundle.")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let starData = try JSONDecoder().decode([StarData].self, from: data)
            let filtered = starData.filter { $0.mag <= maxMagnitude && $0.ra != nil && $0.dec != nil }
            cachedStarData = filtered
            return filtered
        } catch {
            fatalError("❌ Critical error: Failed to load or decode star data: \(error)")
        }
    }
    
    /// Loads and positions stars based on observer's location and current time.
    /// Uses the SAME coordinate system as planets (Az/Alt → Cartesian).
    static func loadStarsForObserver(location: CLLocation, date: Date, maxMagnitude: Double = 6.5) -> [Star] {
        let starData = loadRawStarData(maxMagnitude: maxMagnitude)
        
        print("⭐ Loading \(starData.count) stars for observer at Lat=\(String(format: "%.2f", location.coordinate.latitude))° Lon=\(String(format: "%.2f", location.coordinate.longitude))°")
        
        return starData.map { convertToStar($0, location: location, date: date) }
    }
    
    /// Converts a raw `StarData` object into a renderable `Star` model.
    /// 🎯 NEW: Uses the SAME coordinate conversion as planets (equatorial → horizontal → cartesian)
    private static func convertToStar(_ data: StarData, location: CLLocation, date: Date) -> Star {
        // Step 1: Convert equatorial (RA/Dec) to horizontal (Azimuth/Altitude)
        // This accounts for observer's location and current time (Earth's rotation)
        let horizontal = AstroCalculator.equatorialToHorizontal(
            ra: data.ra!,
            dec: data.dec!,
            for: location,
            at: date
        )
        
        // Step 2: Convert horizontal coordinates to Cartesian 3D rendering coordinates
        // This system is aligned with the user's horizon (same as planets!)
        let finalPosition = AstroCalculator.horizontalToCartesian(
            azimuth: horizontal.azimuth,
            altitude: horizontal.altitude
        )
        
        return Star(
            name: data.name ?? "Star \(data.id)",
            position: finalPosition,
            brightness: magnitudeToBrightness(data.mag),
            size: magnitudeToSize(data.mag),
            color: colorFromBV(data.bv),
            spectralClass: data.sp ?? "Unknown"
        )
    }

    // MARK: - Helper Methods
    
    private static func magnitudeToBrightness(_ magnitude: Double) -> Float {
        return Float(max(0.1, 1.0 - magnitude / 6.5))
    }
    
    private static func magnitudeToSize(_ magnitude: Double) -> Float {
        let normalizedMag = max(0.0, min(6.5, magnitude))
        return max(1.5, Float(8.0 - normalizedMag))
    }

    /// Calculates a star's RGB color based on its B-V (blue-violet) color index.
    private static func colorFromBV(_ bv: Double?) -> (r: Float, g: Float, b: Float) {
        guard let bv = bv else { return (1.0, 1.0, 1.0) } // Default to white if no data.
        let clampedBV = max(-0.4, min(2.0, bv))
        
        // Interpolate between colors based on temperature ranges represented by B-V.
        switch clampedBV {
        case ..<0.0: // Bluish
            let t = Float((clampedBV + 0.4) / 0.4)
            return (r: 0.6 + 0.4 * t, g: 0.7 + 0.3 * t, b: 1.0)
        case 0.0..<0.5: // White
            let t = Float(clampedBV / 0.5)
            return (r: 0.9 + 0.1 * t, g: 0.9 + 0.1 * t, b: 1.0 - 0.2 * t)
        case 0.5..<1.0: // Yellowish
            let t = Float((clampedBV - 0.5) / 0.5)
            return (r: 1.0, g: 1.0 - 0.2 * t, b: 0.8 - 0.3 * t)
        case 1.0..<1.5: // Orangey
            let t = Float((clampedBV - 1.0) / 0.5)
            return (r: 1.0, g: 0.8 - 0.3 * t, b: 0.5 - 0.3 * t)
        default: // Reddish
            let t = Float(min(1.0, (clampedBV - 1.5) / 0.5))
            return (r: 1.0, g: 0.5 - 0.3 * t, b: 0.2 - 0.2 * t)
        }
    }
}
