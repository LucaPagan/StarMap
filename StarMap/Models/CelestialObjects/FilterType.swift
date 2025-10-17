//
//  FilterType.swift
//  StarMap
//
//  Created by Luca Pagano on 10/12/25.
//

import Foundation

/// Defines the filter options for celestial objects.
enum FilterType: String, CaseIterable, Identifiable {
    case all = "All"
    case stars = "Stars"
    case planets = "Planets"
    case nebulae = "Nebulae"

    var id: String { self.rawValue }
}
