//
//  InfoRow.swift
//  StarMap
//
//  Created by Francesco Albano on 10/08/25.
//

import SwiftUI

/// A reusable view for displaying a labeled piece of information with an icon.
struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.blue.opacity(0.8))
                .frame(width: 24, alignment: .center)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(value)
                    .font(.body)
                    .foregroundColor(.white)
            }
            Spacer()
        }
    }
}
