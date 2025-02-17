//
//  Equipment Data Model.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import Foundation

//MARK: Model for Equipment

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
    //Review to add
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
    //user id for specific user
    var reviewHeading: String
    var reviewDescription: String
    var rating: Double
    
}

struct EquipmentMoreImages {
    var images: [String]
}


//MARK: Model for User

struct User {
    let userID: UUID
    var name: String
    var phone: String
    var location: Location
    var selectedCrops: [UUID]
    var fieldArea: Double
    var groupID: UUID?
}

struct Location {
    
    
}

//MARK: Model for Crop

struct Crop {
    let cropID: UUID
    var name: String
    var season: Season
    var equipmentRecommendations: [UUID]
}

enum Season: String {
    case kharif = "Kharif"
    case rabi = "Rabi"
    case zaid = "Zaid"
}


//MARK: Model for Booking

struct Booking {
    let bookingID: UUID
    var userID: UUID
    var equipmentID: UUID
    var bookingType: BookingType
    var bookingDate: Date
    var fieldArea: Double
    var status: BookingStatus
    var timeSlot: TimeSlot
}

enum TimeSlot: String {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
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



//MARK: Model for AgriAssist

struct AgriCrop {
    let id: UUID
    let name: String
    let imageName: String
}

struct CropCategory {
    var id: UUID
    var cropName: String
    var equipmentsForCrops: String
    var equipments: [EquipmentCategory]
}

struct EquipmentCategory {
    let id: UUID
    var title: String
    var equipmentList: [EquipmentAgri]
}

struct EquipmentAgri {
    let id: UUID
    let categoryId: UUID
    var name: String
    var imageName: String
    var purpose: String?
    var bestFor: String?
    var averageCost: String?
    var needs: String?
    var likedBy: Int
}
