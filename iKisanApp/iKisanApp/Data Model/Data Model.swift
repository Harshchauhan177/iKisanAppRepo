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
    
    // Payment-related fields for groups
    var paymentDeadline: Date?  // 4-hour deadline for payment collection
    
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
               lhs.paymentDeadline == rhs.paymentDeadline
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
        acceptedUsers: [UUID]? = nil,
        paymentDeadline: Date? = nil
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
        self.paymentDeadline = paymentDeadline
    }
    
    /// Check if this group is currently collecting payments
    var isCollectingPayment: Bool {
        return status == .collectingPayment
    }
    
    /// Calculate time remaining until payment deadline
    var timeRemainingForPayment: TimeInterval? {
        guard let deadline = paymentDeadline else { return nil }
        return deadline.timeIntervalSinceNow
    }
    
    /// Check if payment deadline has expired
    var hasPaymentExpired: Bool {
        guard let remaining = timeRemainingForPayment else { return false }
        return remaining < 0
    }
}

struct RequestParticipant: Codable, Identifiable, Equatable {
    let id: UUID
    let requestId: UUID
    let userId: UUID
    var status: ParticipantStatus
    var area: Double?           // Area entered by this participant
    var timeSlot: String?       // Time slot selected by this participant
    var joinedAt: Date
    
    // Payment-related fields
    var paymentStatus: PaymentStatus
    var paymentId: String?       // Razorpay Payment ID
    var paymentTimestamp: Date?  // When payment was completed
    var paymentAmount: Double?   // Amount paid by this participant
    
    // Equatable conformance
    static func == (lhs: RequestParticipant, rhs: RequestParticipant) -> Bool {
        return lhs.id == rhs.id &&
               lhs.requestId == rhs.requestId &&
               lhs.userId == rhs.userId &&
               lhs.status == rhs.status &&
               lhs.area == rhs.area &&
               lhs.timeSlot == rhs.timeSlot &&
               lhs.joinedAt == rhs.joinedAt &&
               lhs.paymentStatus == rhs.paymentStatus &&
               lhs.paymentId == rhs.paymentId &&
               lhs.paymentTimestamp == rhs.paymentTimestamp &&
               lhs.paymentAmount == rhs.paymentAmount
    }
    
    // Initializer with default payment status
    init(id: UUID, requestId: UUID, userId: UUID, status: ParticipantStatus, 
         area: Double? = nil, timeSlot: String? = nil, joinedAt: Date,
         paymentStatus: PaymentStatus = .pending, paymentId: String? = nil,
         paymentTimestamp: Date? = nil, paymentAmount: Double? = nil) {
        self.id = id
        self.requestId = requestId
        self.userId = userId
        self.status = status
        self.area = area
        self.timeSlot = timeSlot
        self.joinedAt = joinedAt
        self.paymentStatus = paymentStatus
        self.paymentId = paymentId
        self.paymentTimestamp = paymentTimestamp
        self.paymentAmount = paymentAmount
    }
}

enum ParticipantStatus: String, Codable {
    case pending
    case accepted
    case rejected
    case done
}

/// Payment status for group participants
enum PaymentStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case paid = "paid"
    case failed = "failed"
    case refunded = "refunded"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending Payment"
        case .paid: return "Paid"
        case .failed: return "Payment Failed"
        case .refunded: return "Refunded"
        }
    }
    
    var iconName: String {
        switch self {
        case .pending: return "clock.fill"
        case .paid: return "checkmark.circle.fill"
        case .failed: return "xmark.circle.fill"
        case .refunded: return "arrow.counterclockwise.circle.fill"
        }
    }
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
    var latitude: Double?
    var longitude: Double?
    var address: String?
    
    // Computed property to get booking location as a Location object
    var bookingLocation: Location? {
        get {
            // Only return a location if we have valid coordinates or an address
            let lat = latitude ?? 0.0
            let lon = longitude ?? 0.0
            if lat != 0.0 || lon != 0.0 || (address != nil && !address!.isEmpty) {
                return Location(latitude: lat, longitude: lon, address: address)
            }
            return nil
        }
        set {
            if let newLocation = newValue {
                self.latitude = newLocation.latitude
                self.longitude = newLocation.longitude
                self.address = newLocation.address
            } else {
                self.latitude = nil
                self.longitude = nil
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
         latitude: Double? = nil,
         longitude: Double? = nil,
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
            self.latitude = nil
            self.longitude = nil
            self.address = nil
        }
    }
}

enum BookingStatus: String, Codable {
    case pending = "pending"
    case confirmed = "confirmed"
    case completed = "completed"
    
    // Group payment workflow states
    case awaitingProvider = "awaiting_provider"  // Group filled, waiting for provider acceptance
    case collectingPayment = "collecting_payment" // Provider accepted, participants must pay within 4 hours
    case active = "active"                        // All paid, work in progress
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .confirmed: return "Confirmed"
        case .completed: return "Completed"
        case .awaitingProvider: return "Awaiting Provider"
        case .collectingPayment: return "Collecting Payment"
        case .active: return "Active"
        }
    }
    
    var iconName: String {
        switch self {
        case .pending: return "clock"
        case .confirmed: return "checkmark.circle"
        case .completed: return "checkmark.circle.fill"
        case .awaitingProvider: return "person.crop.circle.badge.clock"
        case .collectingPayment: return "creditcard"
        case .active: return "play.circle.fill"
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

// BookingStatus enum defined above (lines 459-490)
// Removed duplicate definition to fix ambiguity

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

// Commented out to avoid import dependency
// func getSampleUsers() {
//     Task {
//         let crops: [AgriCrop] = try! await SupabaseManager.shared.client
//             .from("agriCrops")
//             .select("*")
//             .execute()
//             .value
//     }
// }
