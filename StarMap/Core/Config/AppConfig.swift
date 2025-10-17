//
//  AppConfig.swift
//  StarMap
//
//  Created by Francesco Albano on 10/07/25.
//

import Foundation
import CoreGraphics

/// Defines global configurations and tuning parameters for the application.
struct AppConfig {
    
    // MARK: - Field of View Settings
    static let defaultFieldOfView: Double = 60.0
    static let minimumFieldOfView: Double = 10.0
    static let maximumFieldOfView: Double = 60.0
    
    // MARK: - Motion Tracking
    static let motionUpdateInterval: TimeInterval = 1.0 / 60.0 // 60 FPS for smooth updates.
    
    // MARK: - Object Selection
    static let selectionTapRadius: Double = 50.0 // Touch radius in pixels for selecting an object.
    
    // MARK: - Rendering
    static let renderingBuffer: Double = 50.0 // Pixels beyond the screen edge to render objects.
    static let brightStarGlowThreshold: Double = 3.0 // Brightness magnitude above which a glow is rendered.
    static let detailedStarSizeThreshold: Double = 2.0 // Minimum size in pixels for detailed multi-layer rendering.
    static let simpleStarSizeThreshold: Double = 1.0 // Minimum size in pixels for simple glow rendering.
    
    // MARK: - Camera Controls
    static let dragSensitivity: Double = 0.01 // Controls how much the view moves per drag point.
    
    // MARK: - Debug
    static let isDebugModeEnabled: Bool = true
}
