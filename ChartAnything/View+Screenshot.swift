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
// └─────────────────────────────────────────────────────────────────┘
extension View {
    /// Renders this view as a high-quality image
    /// - Returns: UIImage of the rendered view, or nil if rendering fails
    @MainActor
    func asImage() -> UIImage? {
        // Create a hosting controller to wrap the SwiftUI view
        let controller = UIHostingController(rootView: self)
        
        // Set a reasonable size (adjust as needed for your charts)
        let targetSize = CGSize(width: 1200, height: 800)
        controller.view.bounds = CGRect(origin: .zero, size: targetSize)
        controller.view.backgroundColor = .clear
        
        // Render the view
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
