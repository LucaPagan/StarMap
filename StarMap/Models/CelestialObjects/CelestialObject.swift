//
//  CelestialObject.swift
//  StarMap
//
//  Created by Francesco Albano on 10/12/25.
//

import Foundation
import SwiftUI

/// A protocol representing any object that can be displayed in the sky.
protocol CelestialObject: Identifiable {
    var id: UUID { get }
    var name: String { get }
    
    /// The object's position in the 3D world space.
    var position: CartesianCoordinates { get }
    
    // MARK: - UI Properties
    var primaryColor: Color { get }
    var size: Float { get }
    
    // MARK: - Info Properties
    var typeName: String { get }
    var details: [String: String] { get }
}
