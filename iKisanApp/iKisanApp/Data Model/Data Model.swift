//
//  Equipment Data Model.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import Foundation

//MARK: Model for Equipment

struct Equipment: Codable, Sendable {
    var equipmentID: UUID
    var equipmentImage: String
    var name: String
    var type: String
    var capacity: String
    var availability: Availability {
        return Availability(startDate: availabilityStartDate, endDate: availabilityEndDate)
    }

    var pricePerHour: Double
    var realPricePerHour: Double
    var pricePerAcre: Double
    var realPricePerAcre: Double

    var providerID: UUID
    var rating: Double
    var location: String
    var coEquipDetail: coEquipState
    var equipmentMoreImages: EquipmentMoreImages {
        return EquipmentMoreImages(images: [])
    }
    var modelYear: String
    var mielage: String
    var description: String?
    var isRecommended: Bool = false//
    var providerName: String?//
    var preBookingStatus: BookingStatus?//
        
    var availabilityStartDate: Date = .init()
    var availabilityEndDate: Date = .init()

    func isAvailable(on date: Date) -> Bool {
        return date >= availability.startDate && date <= availability.endDate
    }
    
    enum CodingKeys: String, CodingKey {
        case equipmentID
        case equipmentImage
        case name
        case type
        case capacity
        case pricePerHour
        case realPricePerHour
        case pricePerAcre
        case realPricePerAcre
        case providerID
        case rating
        case location
        case coEquipDetail
//        case equipmentMoreImages
        case modelYear
        case mielage
        case description
        case isRecommended
        case providerName
        case preBookingStatus
        case availabilityStartDate
        case availabilityEndDate
    }
}

struct Request: Codable, Identifiable {
    let id: UUID
    var userId: UUID
    var equipmentId: UUID
    var requestedDate: Date
    var status: BookingStatus
    var type: BookingType
    var area: Double
    let timeSlot: TimeSlot
    var timePeriod: String?
    var location: String
    var typeOfRequest: RequestType
    var participants: [RequestParticipant]?
    var acceptedUsers: [UUID]?
    
    init(
        id: UUID = UUID(),
        userId: UUID,
        equipmentId: UUID,
        requestedDate: Date,
        status: BookingStatus,
        type: BookingType,
        area: Double,
        timeSlot: TimeSlot,
        timePeriod: String?,
        location: String,
        typeOfRequest: RequestType,
        participants: [RequestParticipant],
        acceptedUsers: [UUID]? = nil
    ) {
        self.id = id
        self.userId = userId
        self.equipmentId = equipmentId
        self.requestedDate = requestedDate
        self.status = status
        self.type = type
        self.area = area
        self.timeSlot = timeSlot
        self.timePeriod = timePeriod
        self.location = location
        self.typeOfRequest = typeOfRequest
        self.participants = participants
        self.acceptedUsers = acceptedUsers
    }
}

struct RequestParticipant: Codable, Identifiable {
    let id: UUID
    let requestId: UUID
    let userId: UUID
    var status: ParticipantStatus
    var area: Double?           // Area entered by this participant
    var timeSlot: String?     // Time slot selected by this participant
    var joinedAt: Date
}

enum ParticipantStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case done
}
// Also make sure RequestType is Codable
enum RequestType: Codable {
    case myRequest
    case acceptedRequest
    case sentRequest
}
struct Availability: Codable {
    var startDate: Date
    var endDate: Date
}


enum coEquipState: String, Codable {
    case Available
    case Unavailable
}

struct ReviewData{
    //user id for specific user
    var reviewHeading: String
    var reviewDescription: String
    var rating: Double
    var equipmentID: String?
    var equipmentName: String?
}

struct EquipmentMoreImages: Codable {
    var images: [String]
    
    enum CodingKeys: String, CodingKey {
        case images
    }
}


//MARK: Model for User

struct User: Codable , Hashable {
    
    
    let userID: UUID
    var name: String
    var email: String
    var phone: String
    var location: Location
    var selectedCrops: [UUID]
    var fieldArea: Double
    var groupID: UUID?
    
    enum CodingKeys: String, CodingKey {
        case userID
        case name
        case email
        case phone
        case location
        case selectedCrops
        case fieldArea
        case groupID
    }
}

struct Location: Codable {
    var latitude: Double
    var longitude: Double
    var address: String?
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
//
enum BookingSource: Codable {
    case home
    case prebooking
    case coEquip
}

//MARK: Model for FAQ

struct FAQ: Codable, Identifiable {
    let id: UUID
    let question: String
    let answer: String
}
//
struct Booking: Codable {
    let bookingID: UUID
    let userID: UUID//
    let equipmentID: UUID//
    let bookingType: BookingType//
    var bookingDate: Date
    var fieldArea: Double
    var status: BookingStatus
    var timeSlot: TimeSlot
    let source: BookingSource//
}

enum TimeSlot: String, Codable {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
}
enum BookingType: String, Codable {
    case onDemand = "On-Demand"
    case prebooking = "Prebooking"
    case coEquip = "Co-Equip"
}

enum BookingStatus: String, Codable {
    case pending = "Pending"
    case confirmed = "Confirmed"
    case completed = "Completed"
}



//MARK: Model for AgriAssist

struct AgriCrop: Codable, Sendable {
    var id: UUID = .init()
    var name: String
    var imageName: String
}

struct CropCategory {
    var id: UUID
    var cropName: String
    var equipmentsForCrops: String
    var equipments: [EquipmentCategory]
}

struct EquipmentCategory: Codable, Sendable {
    let id: UUID
    var title: String
    var equipmentList: [EquipmentAgri] = []
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
    }
}

struct EquipmentAgri: Codable, Sendable {
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
//
//struct FAQ {
//    let id: UUID
//    let question: String
//    let answer: String
//}

let sampleUsers: [User] = [
    User(userID: UUID(), name: "Raj Pal", email: "raj@example.com", phone: "1234567890", location: Location(latitude: 28.6139, longitude: 77.2090, address: "Delhi"), selectedCrops: [], fieldArea: 0.0),
    User(userID: UUID(), name: "Narendra", email: "narendra@example.com", phone: "0987654321", location: Location(latitude: 28.7041, longitude: 77.1025, address: "Delhi"), selectedCrops: [], fieldArea: 0.0),

    User(userID: UUID(), name: "Ramesh Singh", email: "ramesh@example.com", phone: "1234567890", location: Location(latitude: 28.6139, longitude: 77.2090, address: "Delhi"), selectedCrops: [], fieldArea: 0.0),
    User(userID: UUID(), name: "Harsh Kumar", email: "harsh@example.com", phone: "0987654321", location: Location(latitude: 28.7041, longitude: 77.1025, address: "Delhi"), selectedCrops: [], fieldArea: 0.0),

    // Add more sample users as needed

    User(userID: UUID(), name: "John Doe", email: "john@example.com", phone: "1234567890", location: Location(latitude: 28.6139, longitude: 77.2090, address: "Delhi"), selectedCrops: [], fieldArea: 0.0),
    User(userID: UUID(), name: "Jane Smith", email: "jane@example.com", phone: "0987654321", location: Location(latitude: 28.7041, longitude: 77.1025, address: "Delhi"), selectedCrops: [], fieldArea: 0.0),

]
//

func getSampleUsers() {
    Task {
        let crops: [AgriCrop] = try! await SupabaseManager.shared.client
            .from("agriCrops")
            .select("*")
            .execute()
            .value
    }
}
