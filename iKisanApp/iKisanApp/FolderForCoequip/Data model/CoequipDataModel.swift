//
//  File.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import Foundation

struct Equipment {
    var id: UUID
    var name: String
    var pricePerHour: Double
    var pricePerArea: Double
    var rating: Double
    var providerName: String
    var providerLocation: Location
    var imageURL: URL?
    var category: EquipmentCategory
    var availability: [Availability]
}

enum EquipmentCategory: String {
    case tractor
    case plow
    case harvester
    case irrigation
}

struct Availability {
    var date: Date
    var timeSlot: String
    var isAvailable: Bool
}
struct Location {
    var latitude: Double
    var longitude: Double
    var area: String
}
struct Request {
    var id: UUID
    var equipmentId: UUID
    var requestedBy: UUID
    var status: RequestStatus
    var requestedDate: Date
    var requestedTimeSlot: String
    var area: Double
    var location: Location
    var providerId: UUID
    var discountThreshold: Double
    var joinedFarmers: [UUID]
    var minimumAreaForDiscount: Double
}

enum RequestStatus: String {
    case pending
    case confirmed
    case canceled
}

struct User {
    var id: UUID
    var name: String
    var phoneNumber: String
    var location: Location
    var rating: Double
    var profileImage: URL?
    var equipmentOwned: [Equipment]
    var coEquipRequests: [Request]
}


struct Filter {
    var searchText: String
    var category: EquipmentCategory?
    var locationRange: Double
    var minimumRating: Double?
}
