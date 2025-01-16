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
        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 10000, providerID: UUID(), rating: 4.5),
        Equipment(equipmentID: UUID(), equipmentImage: "4.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000, providerID: UUID(), rating: 4.5),
        Equipment(equipmentID: UUID(), equipmentImage: "3.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000, providerID: UUID(), rating: 4.5),
        Equipment(equipmentID: UUID(), equipmentImage: "4.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000, providerID: UUID(), rating: 4.5),
        Equipment(equipmentID: UUID(), equipmentImage: "5.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000, providerID: UUID(), rating: 4.5),
        Equipment(equipmentID: UUID(), equipmentImage: "6.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000, providerID: UUID(), rating: 4.5),
        Equipment(equipmentID: UUID(), equipmentImage: "7.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000, providerID: UUID(), rating: 4.5),
        Equipment(equipmentID: UUID(), equipmentImage: "8.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000, providerID: UUID(), rating: 4.5)
    ]
    

    
    
}
