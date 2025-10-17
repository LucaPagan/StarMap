//
//  BottomControlsOverlay.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import SwiftUI

/// The bottom overlay view containing the object filter controls.
struct BottomControlsOverlay: View {
    let objectCount: Int
    @Binding var activeFilter: FilterType
    
    var body: some View {
        HStack(spacing: 16) {
            Text("🪐 \(objectCount) Objects")
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Picker("Filter", selection: $activeFilter) {
                ForEach(FilterType.allCases) { filter in
                    Text(filter.rawValue).tag(filter)
                }
            }
            .pickerStyle(.segmented)
            .background(Color.black.opacity(0.2))
            .cornerRadius(8)
            .frame(maxWidth: 220)
        }
        .padding()
        .background(.ultraThinMaterial.opacity(Constants.UI.overlayOpacity))
    }
}
