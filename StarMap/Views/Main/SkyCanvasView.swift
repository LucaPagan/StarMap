import SwiftUI
import CoreMotion
import simd

/// The main `Canvas` for rendering all celestial objects and UI elements like the horizon.
struct SkyCanvasView: View {
    let objects: [any CelestialObject]
    
    let rotationMatrix: CMRotationMatrix?
    let manualPitch: Double
    let manualYaw: Double
    let isTrackingMode: Bool
    let fieldOfView: Double
    
    var body: some View {
        Canvas { context, size in
            let screenCenter = CGPoint(x: size.width / 2, y: size.height / 2)
            let scale = size.width / (2 * tan(fieldOfView.toRadians / 2))
            
            // Render horizon and cardinal points
            if isTrackingMode, let matrix = rotationMatrix {
                HorizonRenderer.drawWithMatrix(on: context, size: size, center: screenCenter, scale: scale, matrix: matrix)
                CardinalPointsRenderer.drawWithMatrix(on: context, size: size, center: screenCenter, scale: scale, matrix: matrix)
            } else {
                HorizonRenderer.draw(on: context, size: size, center: screenCenter, scale: scale, pitch: manualPitch, yaw: manualYaw)
                CardinalPointsRenderer.draw(on: context, size: size, center: screenCenter, scale: scale, pitch: manualPitch, yaw: manualYaw)
            }
            
            // Draw all celestial objects
            for obj in objects {
                let rotatedPosition: CartesianCoordinates
                if isTrackingMode, let matrix = rotationMatrix {
                    rotatedPosition = obj.position.rotatedByDeviceMatrix(matrix)
                } else {
                    rotatedPosition = obj.position.rotated(pitch: manualPitch, yaw: manualYaw)
                }

                guard let projectedPoint = SkyRenderer.project(coordinates: rotatedPosition, screenCenter: screenCenter, scale: scale) else {
                    continue
                }
                
                guard SkyRenderer.isOnScreen(point: projectedPoint, screenSize: size) else {
                    continue
                }
                
                // Scale the size based on the field of view to make objects grow when zooming in.
                let zoomFactor = AppConfig.defaultFieldOfView / fieldOfView
                let finalSize = (Double(obj.size) * (1.0 / rotatedPosition.z) * 0.5 * zoomFactor)
                
                if let star = obj as? Star {
                    SkyRenderer.drawStar(
                        on: context,
                        at: projectedPoint,
                        size: finalSize,
                        color: star.primaryColor,
                        brightness: CGFloat(star.brightness),
                        showGlow: Double(star.size) > AppConfig.brightStarGlowThreshold
                    )
                } else if let planet = obj as? Planet {
                    // Make planet images significantly larger for better visibility.
                    let planetSize = finalSize * 7.0
                    
                    SkyRenderer.drawPlanet(
                        on: context,
                        at: projectedPoint,
                        size: planetSize,
                        planet: planet
                    )
                } else if let nebula = obj as? Nebula {
                    // 👈 **MODIFICA CHIAVE**: Ridotto il moltiplicatore per un effetto più sottile.
                    let nebulaSize = finalSize * 10.0
                    
                    SkyRenderer.drawNebula(
                        on: context,
                        at: projectedPoint,
                        size: nebulaSize,
                        nebula: nebula
                    )
                }
            }
        }
    }
}
