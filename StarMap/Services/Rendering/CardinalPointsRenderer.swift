//
//  CardinalPointsRenderer.swift
//  StarMap
//
//  Created by Francesco Albano on 10/12/25.
//

import SwiftUI
import CoreMotion

/// A renderer for drawing the cardinal points (N, E, S, W) on the canvas.
struct CardinalPointsRenderer {
    
    // Define cardinal points in the 3D coordinate system.
    // The X-coordinates of East and West are inverted to fix the specular orientation.
    private static let cardinalPoints: [(point: CartesianCoordinates, name: String)] = [
        (CartesianCoordinates(x: 0, y: 0, z: -1), "N"),
        (CartesianCoordinates(x: -1, y: 0, z: 0), "E"), // x was 1
        (CartesianCoordinates(x: 0, y: 0, z: 1), "S"),
        (CartesianCoordinates(x: 1, y: 0, z: 0), "W")  // x was -1
    ]
    
    /// Draws the points using the device's motion matrix (tracking mode).
    static func drawWithMatrix(on context: GraphicsContext, size: CGSize, center: CGPoint, scale: Double, matrix: CMRotationMatrix) {
        drawPoints(context: context, size: size, center: center, scale: scale) { point in
            point.rotatedByDeviceMatrix(matrix)
        }
    }
    
    /// Draws the points using manual pitch and yaw angles (manual mode).
    static func draw(on context: GraphicsContext, size: CGSize, center: CGPoint, scale: Double, pitch: Double, yaw: Double) {
        drawPoints(context: context, size: size, center: center, scale: scale) { point in
            point.rotated(pitch: pitch, yaw: yaw)
        }
    }
    
    /// Generic drawing logic for the points.
    private static func drawPoints(context: GraphicsContext, size: CGSize, center: CGPoint, scale: Double, rotation: (CartesianCoordinates) -> CartesianCoordinates) {
        for cardinal in cardinalPoints {
            let rotated = rotation(cardinal.point)
            
            guard rotated.isVisible else { continue }
            
            if let projected = SkyRenderer.project(coordinates: rotated, screenCenter: center, scale: scale) {
                // Only draw if the point is within the screen bounds.
                guard projected.x > 0 && projected.x < size.width && projected.y > 0 && projected.y < size.height else { continue }
                
                let text = Text(cardinal.name)
                    .font(.system(size: Constants.UI.cardinalPointFontSize, weight: .bold))
                    .foregroundColor(Constants.Colors.cardinalPoints)
                
                context.draw(text, at: projected)
            }
        }
    }
}
