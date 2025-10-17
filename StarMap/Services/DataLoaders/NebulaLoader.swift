import Foundation
import CoreLocation
import SwiftUI

// A data structure to decode nebula entries from the JSON file.
struct NebulaData: Codable {
    let id: String
    let ra: Double
    let dec: Double
    let mag: Double
    let name: String
    let bv: Double?
    let sp: String?
}

/// A utility to load and parse nebula data from the bundled JSON file.
class NebulaLoader {
    
    // Cache del JSON decodificato per evitare di rileggerlo ogni volta
    private static var cachedNebulaData: [NebulaData]?
    
    /// Loads raw nebula data from JSON and caches it for reuse.
    private static func loadRawNebulaData() -> [NebulaData] {
        if let cached = cachedNebulaData {
            return cached
        }
        
        guard let url = Bundle.main.url(forResource: "nebulae", withExtension: "json") else {
            print("⚠️ Warning: nebulae.json not found in bundle.")
            return []
        }
        
        do {
            let data = try Data(contentsOf: url)
            let nebulaData = try JSONDecoder().decode([NebulaData].self, from: data)
            cachedNebulaData = nebulaData
            return nebulaData
        } catch {
            print("❌ Error: Failed to load or decode nebula data: \(error)")
            return []
        }
    }
    
    /// Loads and positions nebulae based on observer's location and current time.
    /// Uses the SAME coordinate system as planets and stars (Az/Alt → Cartesian).
    static func loadNebulaeForObserver(location: CLLocation, date: Date) -> [Nebula] {
        let nebulaData = loadRawNebulaData()
        
        guard !nebulaData.isEmpty else {
            print("⚠️ No nebula data loaded")
            return []
        }
        
        print("🌌 Loading \(nebulaData.count) nebulae for observer at Lat=\(String(format: "%.2f", location.coordinate.latitude))° Lon=\(String(format: "%.2f", location.coordinate.longitude))°")
        
        return nebulaData.map { convertToNebula($0, location: location, date: date) }
    }
    
    /// Converts a raw `NebulaData` object into a renderable `Nebula` model.
    private static func convertToNebula(_ data: NebulaData, location: CLLocation, date: Date) -> Nebula {
        // Step 1: Convert equatorial (RA/Dec) to horizontal (Azimuth/Altitude)
        // This accounts for observer's location and current time (Earth's rotation)
        let horizontal = AstroCalculator.equatorialToHorizontal(
            ra: data.ra,
            dec: data.dec,
            for: location,
            at: date
        )
        
        // Step 2: Convert horizontal coordinates to Cartesian 3D rendering coordinates
        let finalPosition = AstroCalculator.horizontalToCartesian(
            azimuth: horizontal.azimuth,
            altitude: horizontal.altitude
        )
        
        return Nebula(
            catalogId: data.id,
            name: data.name,
            position: finalPosition,
            ra: data.ra,
            dec: data.dec,
            magnitude: data.mag,
            primaryColor: colorFromBV(data.bv),
            size: magnitudeToSize(data.mag),
            spectralClass: data.sp ?? "Unknown"
        )
    }
    
    // MARK: - Helper Methods
    
    private static func magnitudeToSize(_ magnitude: Double) -> Float {
        // Nebulose più luminose (magnitude bassa) = dimensione maggiore
        let normalizedMag = max(1.0, min(10.0, magnitude))
        return max(8.0, Float(15.0 - normalizedMag))
    }
    
    /// Calculates nebula's color based on its B-V color index.
    private static func colorFromBV(_ bv: Double?) -> Color {
        guard let bv = bv else { return Color(red: 0.8, green: 0.8, blue: 1.0) }
        let clampedBV = max(-0.4, min(2.0, bv))
        
        // Interpolazione colore basata su B-V
        if clampedBV < 0 {
            // Blu (stelle calde)
            let t = (clampedBV + 0.4) / 0.4
            return Color(red: t * 0.6, green: t * 0.7 + 0.3, blue: 1.0)
        } else if clampedBV < 0.5 {
            // Bianco-Blu
            let t = clampedBV / 0.5
            return Color(red: 0.6 + t * 0.4, green: 0.7 + t * 0.3, blue: 1.0 - t * 0.2)
        } else if clampedBV < 1.0 {
            // Bianco-Giallo
            let t = (clampedBV - 0.5) / 0.5
            return Color(red: 1.0, green: 1.0 - t * 0.2, blue: 0.8 - t * 0.4)
        } else {
            // Arancio-Rosso (stelle fredde)
            let t = min(1.0, (clampedBV - 1.0) / 1.0)
            return Color(red: 1.0, green: 0.8 - t * 0.4, blue: 0.4 - t * 0.3)
        }
    }
}
