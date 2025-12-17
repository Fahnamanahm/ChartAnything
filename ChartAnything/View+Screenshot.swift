//
//  View+Screenshot.swift
//  ChartAnything
//
//  Created by Fahnamanahm on 12/14/25.
//

import SwiftUI

// ┌─────────────────────────────────────────────────────────────────┐
// │ VIEW SCREENSHOT EXTENSION                                       │
// │ Converts any SwiftUI View to a high-quality UIImage            │
// │ Using ImageRenderer (iOS 16+)                                  │
// └─────────────────────────────────────────────────────────────────┘
extension View {
    /// Renders this view as a high-quality image
    /// - Returns: UIImage of the rendered view, or nil if rendering fails
    @MainActor
    func asImage() -> UIImage? {
        let targetSize = CGSize(width: 1200, height: 800)
        
        // Use ImageRenderer for proper SwiftUI rendering
        let renderer = ImageRenderer(content: self.frame(width: targetSize.width, height: targetSize.height))
        
        // Set scale for high quality
        renderer.scale = 3.0
        
        // Render to UIImage
        return renderer.uiImage
    }
}
