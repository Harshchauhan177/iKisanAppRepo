//
//  FieldAreaUnit.swift
//  iKisanApp
//
//  Field area measurement units commonly used in India
//

import Foundation

/// Enum representing field area measurement units used in Indian agriculture
enum FieldAreaUnit: String, CaseIterable, Codable {
    case acre = "Acre"
    case hectare = "Hectare"
    case bigha = "Bigha"
    case katha = "Katha"
    case gunta = "Gunta"
    
    /// Display name for the unit
    var displayName: String {
        rawValue
    }
    
    /// Short symbol for the unit
    var symbol: String {
        switch self {
        case .acre:
            return "ac"
        case .hectare:
            return "ha"
        case .bigha:
            return "bigha"
        case .katha:
            return "katha"
        case .gunta:
            return "gunta"
        }
    }
    
    /// Conversion factor to acres (base unit)
    /// Note: Bigha, Katha, and Gunta sizes vary by region. Using common conversions.
    var toAcresFactor: Double {
        switch self {
        case .acre:
            return 1.0
        case .hectare:
            return 2.471 // 1 hectare = 2.471 acres
        case .bigha:
            return 0.625 // 1 bigha ≈ 0.625 acres (standard bigha, varies by region)
        case .katha:
            return 0.0333 // 1 katha ≈ 0.0333 acres (approximately 1/30th of a bigha)
        case .gunta:
            return 0.025 // 1 gunta ≈ 0.025 acres
        }
    }
    
    /// Convert value from this unit to acres
    /// - Parameter value: The value in current unit
    /// - Returns: Equivalent value in acres
    func convertToAcres(_ value: Double) -> Double {
        return value * toAcresFactor
    }
    
    /// Convert value from acres to this unit
    /// - Parameter acres: The value in acres
    /// - Returns: Equivalent value in this unit
    func convertFromAcres(_ acres: Double) -> Double {
        return acres / toAcresFactor
    }
}
