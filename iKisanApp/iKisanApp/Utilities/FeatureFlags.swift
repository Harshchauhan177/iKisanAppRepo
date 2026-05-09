//
//  FeatureFlags.swift
//  iKisanApp
//
//  Centralized feature flags for controlling feature availability.
//  Toggle these flags to enable/disable features across the app.
//

import Foundation

// MARK: - Feature Flags

/// Centralized feature flags for controlling feature availability.
/// Toggle these flags to enable/disable features across the app.
enum FeatureFlags {
    
    /// Controls whether Razorpay online payment is available in the UI.
    /// Set to `true` to re-enable Razorpay for future releases.
    /// When `false`, the app defaults to Cash on Delivery (COD) for all payment flows.
    static let isRazorpayEnabled: Bool = false
}

// MARK: - Payment Method

/// Represents the available payment methods in the app.
/// Used across checkout flows to determine payment routing.
enum PaymentMethod: String, Codable, CaseIterable, Identifiable {
    case cashOnDelivery = "cod"
    case razorpay = "razorpay"
    
    var id: String { rawValue }
    
    /// User-facing display name
    var displayName: String {
        switch self {
        case .cashOnDelivery: return "Cash on Delivery"
        case .razorpay: return "Pay Online"
        }
    }
    
    /// Secondary descriptive text shown below the title
    var subtitle: String {
        switch self {
        case .cashOnDelivery: return "Pay when your order arrives"
        case .razorpay: return "Pay securely via UPI, Card, or Netbanking"
        }
    }
    
    /// SF Symbol icon name for the payment method
    var iconName: String {
        switch self {
        case .cashOnDelivery: return "banknote"
        case .razorpay: return "creditcard.fill"
        }
    }
    
    /// Available payment methods based on current feature flags
    static var availableMethods: [PaymentMethod] {
        var methods: [PaymentMethod] = [.cashOnDelivery]
        if FeatureFlags.isRazorpayEnabled {
            methods.append(.razorpay)
        }
        return methods
    }
}
