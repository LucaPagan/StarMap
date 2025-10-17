//
//  CartesianCoordinates.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import Foundation
import CoreMotion
import simd

/// Represents a point in a 3D right-handed Cartesian coordinate system.
struct CartesianCoordinates {
    let x: Double
    let y: Double
    let z: Double
    
    /// Determines if the coordinate is in front of the camera (in the positive Z direction).
    var isVisible: Bool {
        return z > 0
    }
    
    /// Rotates the coordinate based on the device's live motion data.
    func rotatedByDeviceMatrix(_ matrix: CMRotationMatrix) -> CartesianCoordinates {
        
        // A pre-rotation of -90 degrees around the Y-axis aligns the gyroscope's
        // coordinate system (X=North) with the app's internal system (-Z=North).
        let yawCorrectionAngle = -Double.pi / 2
        let cosYaw = cos(yawCorrectionAngle)
        let sinYaw = sin(yawCorrectionAngle)
        
        // Apply the calibration rotation.
        let calibratedX = self.x * cosYaw - self.z * sinYaw
        let calibratedZ = self.x * sinYaw + self.z * cosYaw
        let calibratedY = self.y
        
        // CoreMotion's matrix is landscape-oriented by default.
        // We perform a coordinate shuffle to match the portrait UI.
        let portraitX = calibratedX
        let portraitY = calibratedZ
        let portraitZ = -calibratedY
        
        // Apply the device's rotation matrix to the calibrated and oriented coordinates.
        // The matrix is inverted (negated) to simulate moving the world instead of the camera.
        let newX = -(matrix.m11 * portraitX + matrix.m12 * portraitY + matrix.m13 * portraitZ)
        let newY = -(matrix.m21 * portraitX + matrix.m22 * portraitY + matrix.m23 * portraitZ)
        let newZ = matrix.m31 * portraitX + matrix.m32 * portraitY + matrix.m33 * portraitZ
        
        return CartesianCoordinates(x: newX, y: newY, z: newZ)
    }

    /// Rotates the coordinate based on manual drag gestures (pitch and yaw).
    func rotated(pitch: Double, yaw: Double) -> CartesianCoordinates {
        // Apply yaw rotation (around the world's Y-axis).
        let cosYaw = cos(-yaw)
        let sinYaw = sin(-yaw)
        let x1 = x * cosYaw - z * sinYaw
        let z1 = x * sinYaw + z * cosYaw
        let y1 = y
        
        // Apply pitch rotation (around the world's X-axis).
        let cosPitch = cos(-pitch)
        let sinPitch = sin(-pitch)
        let y2 = y1 * cosPitch - z1 * sinPitch
        let z2 = y1 * sinPitch + z1 * cosPitch
        let x2 = x1
        
        return CartesianCoordinates(x: x2, y: y2, z: z2)
    }
}
