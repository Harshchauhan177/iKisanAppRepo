//
//  SwiftUIUtilities.swift
//  iKisanApp
//
//  Created on 09/02/26.
//  Shared SwiftUI utilities and custom shapes
//

import SwiftUI

// MARK: - Custom Corner Radius Shape

/// A custom shape that allows rounding specific corners of a view
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - View Extension for Selective Corner Radius

extension View {
    /// Apply corner radius to specific corners
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
