//
//  File.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import Foundation
import UIKit



struct CoequipEquipment {
    var id: UUID
    var name: String?
    var pricePerHour: Double
    var pricePerArea: Double
    var rating: Double
    var providerName: String? 
    var providerLocation: CoequipLocation
    var imageURL: UIImage
    var category: EquipmentCategory
    var availability: [CoequipAvailability]
    var description: String?
    var reviews: [Review]?
}

struct Request {
    var id: UUID
    var equipmentId: UUID
    var requestedBy: UUID
    var status: RequestStatus
    var requestedDate: Date
    var requestedTimeSlot: String
    var area: Double
    var location: String
    var providerId: UUID
    var discountThreshold: Double
    var joinedFarmers: [UUID]
    var minimumAreaForDiscount: Double
    var paymentStatus: PaymentStatus
    var statusUpdatedDate: Date?
    var notes: String?
}

struct Review {
    var userId: UUID
    var rating: Double
    var comment: String
}
enum EquipmentCategory: String {
    case tractor
    case plow
    case harvester
    case irrigation
}

struct CoequipAvailability {
    var date: Date
    var timeSlot: String
    var isAvailable: Bool
}
struct CoequipLocation {
    var latitude: Double
    var longitude: Double
    var area: String
}

enum PaymentStatus: String {
    case pending
    case completed
    case failed
}

enum RequestStatus: String {
    case pending
    case confirmed
    case canceled
}

struct CoequipUser {
    var id: UUID
    var name: String?
    var phoneNumber: String
    var location: String
}
enum UserType {
    case farmer
    case provider
}


struct Filter {
    var searchText: String
    var category: EquipmentCategory?
    var locationRange: Double
    var minimumRating: Double?
}
// Define sample users
let sampleUsers: [CoequipUser] = [
    CoequipUser(id: UUID(), name: "John Doe", phoneNumber: "123-456-7890", location: "California"),
    CoequipUser(id: UUID(), name: "Jane Smith", phoneNumber: "987-654-3210", location: "Texas"),
    CoequipUser(id: UUID(), name: "Bob Brown", phoneNumber: "555-123-4567", location: "Florida"),
    CoequipUser(id: UUID(), name: "Alice White", phoneNumber: "555-765-4321", location: "New York")
]
