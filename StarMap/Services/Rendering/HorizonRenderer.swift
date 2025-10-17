//
//  HorizonRenderer.swift
//  StarMap
//
//  Created by Francesco Albano on 10/12/25.
//

import SwiftUI
import CoreMotion

/// A renderer for drawing the horizon line on the canvas.
struct HorizonRenderer {

    /// Draws the horizon using the device's motion matrix (tracking mode).
    static func drawWithMatrix(on context: GraphicsContext, size: CGSize, center: CGPoint, scale: Double, matrix: CMRotationMatrix) {
        drawHorizon(context: context, size: size, center: center, scale: scale) { point in
            point.rotatedByDeviceMatrix(matrix)
        }
    }

    /// Draws the horizon using manual pitch and yaw angles (manual mode).
    static func draw(on context: GraphicsContext, size: CGSize, center: CGPoint, scale: Double, pitch: Double, yaw: Double) {
        drawHorizon(context: context, size: size, center: center, scale: scale) { point in
            point.rotated(pitch: pitch, yaw: yaw)
        }
    }

    /// Generic drawing logic for the horizon line.
    private static func drawHorizon(context: GraphicsContext, size: CGSize, center: CGPoint, scale: Double, rotation: (CartesianCoordinates) -> CartesianCoordinates) {
        var horizonPath = Path()
        var lastProjectedPoint: CGPoint?

        // Generate points along the horizon circle.
        for angle in stride(from: 0, through: 360, by: 5) {
            let radians = Double(angle).toRadians
            // Apply specular inversion to the x-coordinate to fix East/West orientation.
            let horizonPoint = CartesianCoordinates(x: -sin(radians), y: 0, z: cos(radians))
            
            let rotated = rotation(horizonPoint)
            
            if let projected = SkyRenderer.project(coordinates: rotated, screenCenter: center, scale: scale) {
                // Connect points into a continuous line, handling jumps at the screen edges.
                if let lastPoint = lastProjectedPoint, abs(lastPoint.x - projected.x) < size.width / 2 {
                    horizonPath.addLine(to: projected)
                } else {
                    horizonPath.move(to: projected)
                }
                lastProjectedPoint = projected
            } else {
                lastProjectedPoint = nil
            }
        }
        
        context.stroke(
            horizonPath,
            with: .color(Constants.Colors.horizonLine),
            style: StrokeStyle(lineWidth: Constants.UI.horizonLineWidth, lineCap: .round)
        )
    }
}
