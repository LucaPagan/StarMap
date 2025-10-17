import SwiftUI
import Combine
import CoreMotion
import CoreLocation
import SwissEphemeris

@MainActor
class StarMapViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var fieldOfView: Double = AppConfig.defaultFieldOfView
    @Published var isTrackingMode: Bool = true
    @Published var selectedObject: (any CelestialObject)?
    @Published var showObjectInfo: Bool = false
    @Published var activeFilter: FilterType = .all
    @Published var planets: [Planet]

    // MARK: - Manual Camera Control
    @Published var manualPitch: Double = 0
    @Published var manualYaw: Double = 0
    
    // MARK: - Data Stores
    @Published var stars: [Star]
    @Published var nebulae: [Nebula]
    
    var filteredObjects: [any CelestialObject] {
        switch activeFilter {
        case .all: return stars + planets + nebulae
        case .stars: return stars
        case .planets: return planets
        case .nebulae: return nebulae
        }
    }
    
    // MARK: - Internal State
    private var lastDragTranslation: CGSize = .zero
    private var lastMagnification: CGFloat = 1.0
    private var lastUpdateTime: Date?
    private var objectsLoaded: Bool = false  // Track if stars/nebulae have been loaded
    private(set) var currentLocation: CLLocation?

    // MARK: - Initialization
    init() {
        JPLFileManager.setEphemerisPath()
        
        // Initialize with empty arrays - will be populated when location is available
        self.stars = []
        self.planets = []
        self.nebulae = []
        
        print("ViewModel initialized. Waiting for location to load celestial objects.")
    }
    
    // MARK: - Data Handling
    
    /// Called when the app becomes active to allow for a data refresh.
    func forceDataRefreshOnAppActive() {
        print("App became active. Forcing data refresh on next location update.")
        // Force immediate refresh by clearing flags
        self.lastUpdateTime = nil
        self.objectsLoaded = false
    }
    
    /// This is the single, authoritative function for updating celestial object data.
    func updateData(for location: CLLocation) {
        let now = Date()
        
        self.currentLocation = location
        
        // Load stars and nebulae ONCE when location is first available or when app reopens
        if !objectsLoaded {
            print("⭐ Loading stars for the first time...")
            self.stars = StarDataLoader.loadStarsForObserver(
                location: location,
                date: now,
                maxMagnitude: 6.5
            )
            print("✅ \(stars.count) stars loaded successfully.")
            
            // Load nebulae at the same time as stars
            print("🌌 Loading nebulae...")
            self.nebulae = NebulaLoader.loadNebulaeForObserver(
                location: location,
                date: now
            )
            print("✅ \(nebulae.count) nebulae loaded successfully.")
            self.objectsLoaded = true
        }
        
        // Update planets periodically (every 60 seconds)
        let shouldUpdatePlanets: Bool
        if let lastTime = lastUpdateTime {
            shouldUpdatePlanets = now.timeIntervalSince(lastTime) >= 60.0
        } else {
            shouldUpdatePlanets = true // First update or forced refresh
        }
        
        guard shouldUpdatePlanets else { return }
        
        print("🪐 Updating planets for time: \(now)")
        
        var freshPlanets = PlanetProvider.createPlanetsForDate(now)
        
        for i in 0..<freshPlanets.count {
            let planet = freshPlanets[i]
            
            let horizontal = AstroCalculator.equatorialToHorizontal(
                ra: planet.ra,
                dec: planet.dec,
                for: location,
                at: now
            )
            
            let finalPosition = AstroCalculator.horizontalToCartesian(
                azimuth: horizontal.azimuth,
                altitude: horizontal.altitude
            )
            
            freshPlanets[i].position = finalPosition
        }

        self.planets = freshPlanets
        self.lastUpdateTime = now

        print("✅ \(freshPlanets.count) planets updated successfully.")
    }
    
    // ... (Il resto del ViewModel non cambia)
    func handleDrag(translation: CGSize, motionManager: MotionManager, locationManager: LocationManager) {
        if isTrackingMode {
            isTrackingMode = false
            manualPitch = motionManager.pitch
            manualYaw = locationManager.compassHeading.toRadians
        }
        
        let deltaX = translation.width - lastDragTranslation.width
        let deltaY = translation.height - lastDragTranslation.height
        
        manualYaw -= deltaX * AppConfig.dragSensitivity
        manualPitch += deltaY * AppConfig.dragSensitivity
        
        lastDragTranslation = translation
    }
    
    func endDrag() {
        lastDragTranslation = .zero
    }
    
    func handleZoom(magnification: CGFloat) {
        let delta = magnification / lastMagnification
        lastMagnification = magnification
        
        fieldOfView /= Double(delta)
        fieldOfView = max(AppConfig.minimumFieldOfView, min(AppConfig.maximumFieldOfView, fieldOfView))
    }
    
    func endZoom() {
        lastMagnification = 1.0
    }
    
    func resumeTracking() {
        withAnimation(.spring(response: 0.3)) {
            isTrackingMode = true
        }
    }
    
    func findClosestObject(at location: CGPoint, rotationMatrix: CMRotationMatrix?, screenSize: CGSize) -> (any CelestialObject)? {
        let objectsToSearch = filteredObjects
        let centerX = screenSize.width / 2
        let centerY = screenSize.height / 2
        let scale = screenSize.width / (2 * tan(fieldOfView.toRadians / 2))
        
        var closestObject: (any CelestialObject)? = nil
        var minDistance: Double = AppConfig.selectionTapRadius
        
        for obj in objectsToSearch {
            let rotated: CartesianCoordinates
            if let matrix = rotationMatrix, isTrackingMode {
                rotated = obj.position.rotatedByDeviceMatrix(matrix)
            } else {
                rotated = obj.position.rotated(pitch: manualPitch, yaw: manualYaw)
            }
            
            if let projected = SkyRenderer.project(coordinates: rotated, screenCenter: CGPoint(x: centerX, y: centerY), scale: scale) {
                let distance = hypot(projected.x - location.x, projected.y - location.y)
                if distance < minDistance {
                    minDistance = distance
                    closestObject = obj
                }
            }
        }
        return closestObject
    }
    
    func selectObject(_ object: any CelestialObject) {
        if var planet = object as? Planet {
            let distance = Coordinate<SwissEphemeris.Planet>(body: planet.body, date: Date()).distance
            planet.distanceAU = distance
            self.selectedObject = planet
        } else {
            self.selectedObject = object
        }
        self.showObjectInfo = true
    }
    
    func deselectObject() {
        withAnimation(.easeOut(duration: 0.2)) { showObjectInfo = false }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { self.selectedObject = nil }
    }
}
