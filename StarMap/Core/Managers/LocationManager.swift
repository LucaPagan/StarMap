//
//  LocationManager.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import CoreLocation
import Combine

/// Manages GPS location and compass updates using CoreLocation.
class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    /// A shared singleton instance for easy access throughout the app.
    static let shared = LocationManager()
    
    private let manager = CLLocationManager()
    
    @Published var currentLocation: CLLocation?
    @Published var compassHeading: Double = 0.0
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 1 // Notify on 1-degree changes for responsive heading.
    }
    
    /// Starts requesting location and heading updates.
    func startUpdating() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }
    
    /// Stops location and heading updates to save battery.
    func stopUpdating() {
        manager.stopUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            manager.stopUpdatingHeading()
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        compassHeading = newHeading.magneticHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("❌ Location Manager Error: \(error.localizedDescription)")
    }
}
