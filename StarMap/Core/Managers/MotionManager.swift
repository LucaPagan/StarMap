//
//  MotionManager.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import CoreMotion
import Combine
import simd

/// Manages device motion updates using CoreMotion to track the device's orientation.
@MainActor
class MotionManager: ObservableObject {
    
    @Published var rotationMatrix: CMRotationMatrix = CMRotationMatrix()
    
    // Optional properties for debugging or other UI purposes.
    @Published var pitch: Double = 0
    @Published var yaw: Double = 0
    @Published var roll: Double = 0
    
    private let motionManager = CMMotionManager()

    /// Starts tracking device motion updates at a high frequency.
    func startTracking() {
        guard motionManager.isDeviceMotionAvailable else {
            print("⚠️ Device motion is not available on this device.")
            return
        }
        
        motionManager.deviceMotionUpdateInterval = AppConfig.motionUpdateInterval
        
        // Use the xMagneticNorthZVertical reference frame, which provides orientation
        // relative to magnetic north and gravity. This is ideal for AR/stargazing apps.
        motionManager.startDeviceMotionUpdates(
            using: .xMagneticNorthZVertical,
            to: .main
        ) { [weak self] motion, error in
            guard let self = self, let motion = motion else {
                if let error = error {
                    print("❌ Motion Manager Error: \(error.localizedDescription)")
                }
                return
            }
            
            let attitude = motion.attitude
            
            // Update published properties on the main thread.
            self.rotationMatrix = attitude.rotationMatrix
            self.pitch = attitude.pitch
            self.yaw = attitude.yaw
            self.roll = attitude.roll
        }
    }
    
    /// Stops tracking device motion to conserve power.
    func stopTracking() {
        if motionManager.isDeviceMotionActive {
            motionManager.stopDeviceMotionUpdates()
        }
    }
}
