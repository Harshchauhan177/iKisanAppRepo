//
//  Equipment Data Model.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import Foundation

struct Equipment {
    let equipmentID: UUID
    var equipmentImage: String
    var name: String
    var type: String
    var capacity: String
    var availability: Availability
    var pricePerHour: Double
    var realPricePerHour: Double
    var pricePerAcre: Double
    var realPricePerAcre: Double
    var providerID: UUID
    var rating: Double
    var location: String
    var coEquipDetail: coEquipState
    var equipmentMoreImages: EquipmentMoreImages
    var modelYear: String
    var mielage: String
    var description: String?
    func isAvailable(on date: Date) -> Bool {
        return date >= availability.startDate && date <= availability.endDate
    }
}

struct Availability {
    var startDate: Date
    var endDate: Date
}

enum coEquipState{
    case Available
    case Unavailable
}

struct ReviewData{
    var reviewHeading: String
    var reviewDescription: String
    var rating: Double
    
}

struct EquipmentMoreImages {
    var images: [String]
}




