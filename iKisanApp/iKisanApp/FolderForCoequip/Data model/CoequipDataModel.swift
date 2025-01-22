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
    var imageURL: [URL]?
    var category: EquipmentCategory
    var availability: [Availability]
    var description: String?
    var reviews: [Review]?
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
    var paymentStatus: PaymentStatus
    var statusUpdatedDate: Date?
    var notes: String?
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

struct User {
    var id: UUID
    var name: String
    var phoneNumber: String
    var email: String?
    var location: Location
    var rating: Double
    var profileImage: URL?
    var equipmentOwned: [Equipment]
    var coEquipRequests: [Request]
    var userType: UserType
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

