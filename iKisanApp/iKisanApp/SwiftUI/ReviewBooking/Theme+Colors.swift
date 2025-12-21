//
//  Theme+Colors.swift
//  iKisanApp
//
//  Design System - Colors & Theme
//

import SwiftUI

extension Color {
    /// iKisan brand green color - used for primary actions and accents
    static let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    /// Lighter version of iKisan green for backgrounds
    static let ikisanGreenLight = Color(red: 0.298, green: 0.498, blue: 0.345).opacity(0.1)
    
    /// Background colors that adapt to light/dark mode
    static let cardBackground = Color(.systemBackground)
    static let screenBackground = Color(.systemGray6)
}

extension UIColor {
    /// iKisan brand green color - UIKit version
    static let ikisanGreen = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
}
