//
//  Equipment Data Model.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import Foundation

//MARK: Model for Equipment

struct Equipment: Codable, Sendable, Hashable {
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
    var equipmentMoreImages: EquipmentMoreImages = EquipmentMoreImages(images: [])
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
    
    // Hashable conformance - use equipmentID for equality and hashing
    static func == (lhs: Equipment, rhs: Equipment) -> Bool {
        lhs.equipmentID == rhs.equipmentID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(equipmentID)
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

struct Request: Codable, Identifiable, Equatable {
    let id: UUID
    var userId: UUID
    var equipmentId: UUID
    var requestedDate: Date
    var status: BookingStatus
    var type: BookingType
    var area: Double
    var timeSlot: TimeSlot
    var timePeriod: String?
    var location: String
    var typeOfRequest: RequestType
    var participants: [RequestParticipant]?
    var acceptedUsers: [UUID]?
    
    // Equatable conformance
    static func == (lhs: Request, rhs: Request) -> Bool {
        return lhs.id == rhs.id &&
               lhs.userId == rhs.userId &&
               lhs.equipmentId == rhs.equipmentId &&
               lhs.requestedDate == rhs.requestedDate &&
               lhs.status == rhs.status &&
               lhs.type == rhs.type &&
               lhs.area == rhs.area &&
               lhs.timeSlot == rhs.timeSlot &&
               lhs.timePeriod == rhs.timePeriod &&
               lhs.location == rhs.location &&
               lhs.typeOfRequest == rhs.typeOfRequest &&
               lhs.participants == rhs.participants &&
               lhs.acceptedUsers == rhs.acceptedUsers
    }
    
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

struct RequestParticipant: Codable, Identifiable, Equatable {
    let id: UUID
    let requestId: UUID
    let userId: UUID
    var status: ParticipantStatus
    var area: Double?           // Area entered by this participant
    var timeSlot: String?     // Time slot selected by this participant
    var joinedAt: Date
    
    // Equatable conformance
    static func == (lhs: RequestParticipant, rhs: RequestParticipant) -> Bool {
        return lhs.id == rhs.id &&
               lhs.requestId == rhs.requestId &&
               lhs.userId == rhs.userId &&
               lhs.status == rhs.status &&
               lhs.area == rhs.area &&
               lhs.timeSlot == rhs.timeSlot &&
               lhs.joinedAt == rhs.joinedAt
    }
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

struct ReviewData: Identifiable {
    var id: UUID = UUID()
    var reviewerName: String = "Anonymous"
    var date: Date = Date()
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

// Model for individual equipment image from equipmentMoreImages table
struct EquipmentImageRecord: Codable {
    let id: Int
    let equipmentID: UUID?
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case equipmentID
        case image
    }
}


//MARK: Model for User

struct User: Codable, Hashable, Identifiable {
    
    var id: UUID { userID }
    
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

//struct Crop {
//    let cropID: UUID
//    var name: String
//    var season: Season
//    var equipmentRecommendations: [UUID]
//    var imageURL: String?
//}

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
    case coEquipViewOnly  // New case for view-only mode from request cards
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
    var latitude: Double = 0.0
    var longitude: Double = 0.0
    var address: String?
    
    // Computed property to get booking location as a Location object
    var bookingLocation: Location? {
        get {
            // Only return a location if we have valid coordinates or an address
            if latitude != 0.0 || longitude != 0.0 || (address != nil && !address!.isEmpty) {
                return Location(latitude: latitude, longitude: longitude, address: address)
            }
            return nil
        }
        set {
            if let newLocation = newValue {
                self.latitude = newLocation.latitude
                self.longitude = newLocation.longitude
                self.address = newLocation.address
            } else {
                self.latitude = 0.0
                self.longitude = 0.0
                self.address = nil
            }
        }
    }
    
    // Default initializer
    init(bookingID: UUID = UUID(), 
         userID: UUID, 
         equipmentID: UUID, 
         bookingType: BookingType, 
         bookingDate: Date, 
         fieldArea: Double, 
         status: BookingStatus, 
         timeSlot: TimeSlot, 
         source: BookingSource, 
         latitude: Double = 0.0,
         longitude: Double = 0.0,
         address: String? = nil) {
        self.bookingID = bookingID
        self.userID = userID
        self.equipmentID = equipmentID
        self.bookingType = bookingType
        self.bookingDate = bookingDate
        self.fieldArea = fieldArea
        self.status = status
        self.timeSlot = timeSlot
        self.source = source
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
    }
    
    // Convenience initializer with a Location object
    init(bookingID: UUID = UUID(), 
         userID: UUID, 
         equipmentID: UUID, 
         bookingType: BookingType, 
         bookingDate: Date, 
         fieldArea: Double, 
         status: BookingStatus, 
         timeSlot: TimeSlot, 
         source: BookingSource, 
         bookingLocation: Location? = nil) {
        self.bookingID = bookingID
        self.userID = userID
        self.equipmentID = equipmentID
        self.bookingType = bookingType
        self.bookingDate = bookingDate
        self.fieldArea = fieldArea
        self.status = status
        self.timeSlot = timeSlot
        self.source = source
        
        if let location = bookingLocation {
            self.latitude = location.latitude
            self.longitude = location.longitude
            self.address = location.address
        } else {
            self.latitude = 0.0
            self.longitude = 0.0
            self.address = nil
        }
    }
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

// Crop struct specifically for Select Crops functionality
struct Crop {
    let id: UUID
    let name: String
    let imageURL: String
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
