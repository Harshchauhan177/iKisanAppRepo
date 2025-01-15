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
    var providerID: UUID
    var rating: Double
    func isAvailable(on date: Date) -> Bool {
        return date >= availability.startDate && date <= availability.endDate
    }
}

struct Availability {
    var startDate: Date
    var endDate: Date
}

class EquipmentData{
    static var equipment: [Equipment] = [
        Equipment(equipmentID: UUID(), equipmentImage: "equipment1", name: "Tractor", type: "Agricultural", capacity: "10000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 10000, providerID: UUID(), rating: 4.5)
    ]
    
    
}
