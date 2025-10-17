//
//  Double+Astronomy.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import Foundation

extension Double {
    /// Normalizes an angle in degrees to the range [0, 360).
    var normalizedDegrees: Double {
        var normalized = self.truncatingRemainder(dividingBy: 360)
        if normalized < 0 {
            normalized += 360
        }
        return normalized
    }
    
    /// Converts an angle from radians to degrees.
    var toDegrees: Double {
        return self * 180 / .pi
    }
    
    /// Converts an angle from degrees to radians.
    var toRadians: Double {
        return self * .pi / 180
    }
    
    /// Returns the cardinal direction name (e.g., "N", "SW") for an angle in degrees.
    var cardinalDirectionName: String {
        let normalized = self.normalizedDegrees
        let index = Int((normalized + 22.5) / 45.0) % 8
        return Constants.cardinalDirections[index]
    }
}

extension Date {
    /// Calculates the Julian Day for the current date instance.
    /// The Julian Day is the continuous count of days since the beginning of the Julian period.
    var julianDay: Double {
        return self.timeIntervalSince1970 / 86400.0 + 2440587.5
    }
}
