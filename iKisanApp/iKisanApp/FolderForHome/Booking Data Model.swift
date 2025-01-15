//
//  Crop Data Model.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import Foundation

struct Booking {
    let bookingID: UUID
    var userID: UUID
    var equipmentID: UUID
    var bookingType: BookingType
    var bookingDate: Date
    var fieldArea: Double
    var status: BookingStatus
}

enum BookingType: String {
    case onDemand = "On-Demand"
    case prebooking = "Prebooking"
    case coEquip = "Co-Equip"
}

enum BookingStatus: String {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case completed = "Completed"
}
