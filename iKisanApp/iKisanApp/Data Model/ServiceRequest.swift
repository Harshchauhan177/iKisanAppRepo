//
//  ServiceRequest.swift
//  iKisanApp
//
//  Created for consumer-side active job tracking.
//  Maps to the 'servicerequests' table in Supabase.
//

import Foundation

// MARK: - ServiceRequest Model
/// Represents an active service request created when a provider accepts a booking.
/// This model maps to the 'servicerequests' table used by the provider app.
struct ServiceRequest: Codable, Identifiable, Equatable {
    let id: UUID
    let farmerId: UUID                    // The consumer/farmer who made the request
    let equipmentName: String             // Equipment name or ID
    var amount: Double                    // Total amount for the service
    var date: Date                        // Scheduled date for the service
    var status: ServiceRequestStatus      // Current status (usually "inProgress")
    var type: ServiceRequestType          // "individual" or "coequip"
    var area: Double                      // Field area in acres
    var timeSlot: String                  // Time slot (Morning/Afternoon/Evening)
    var timePeriod: String                // Time period description
    var location: String                  // Location/address for the service
    var joinedUser: UUID?                 // For coequip: joined user ID (optional)

    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case id
        case farmerId = "farmerid"
        case equipmentName = "equipmentname"
        case amount
        case date
        case status
        case type
        case area
        case timeSlot = "timeslot"
        case timePeriod = "timeperiod"
        case location
        case joinedUser = "joineduser"
    }

    // MARK: - Equatable
    static func == (lhs: ServiceRequest, rhs: ServiceRequest) -> Bool {
        return lhs.id == rhs.id
    }

    // MARK: - Memberwise Initializer
    init(
        id: UUID = UUID(),
        farmerId: UUID,
        equipmentName: String,
        amount: Double,
        date: Date,
        status: ServiceRequestStatus,
        type: ServiceRequestType,
        area: Double,
        timeSlot: String,
        timePeriod: String,
        location: String,
        joinedUser: UUID? = nil
    ) {
        self.id = id
        self.farmerId = farmerId
        self.equipmentName = equipmentName
        self.amount = amount
        self.date = date
        self.status = status
        self.type = type
        self.area = area
        self.timeSlot = timeSlot
        self.timePeriod = timePeriod
        self.location = location
        self.joinedUser = joinedUser
    }

    // MARK: - Defensive Custom Decoder
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        // Required UUID field
        id = try container.decode(UUID.self, forKey: .id)

        // Farmer ID - handle both UUID and String formats
        if let farmerUUID = try? container.decode(UUID.self, forKey: .farmerId) {
            farmerId = farmerUUID
        } else if let farmerString = try? container.decode(String.self, forKey: .farmerId),
                  let farmerUUID = UUID(uuidString: farmerString) {
            farmerId = farmerUUID
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .farmerId,
                in: container,
                debugDescription: "farmerId must be a valid UUID"
            )
        }

        // Equipment name - can be a string or UUID
        if let name = try? container.decode(String.self, forKey: .equipmentName) {
            equipmentName = name
        } else if let equipUUID = try? container.decode(UUID.self, forKey: .equipmentName) {
            equipmentName = equipUUID.uuidString
        } else {
            equipmentName = ""
        }

        // DEFENSIVE: amount field - default to 0.0 if null or missing
        if let decodedAmount = try? container.decodeIfPresent(Double.self, forKey: .amount) {
            amount = decodedAmount
        } else {
            amount = 0.0
        }

        // Defensive date decoding
        date = Self.decodeFlexibleDate(from: container, forKey: .date) ?? Date()

        // Status with fallback to .inProgress
        if let statusString = try? container.decode(String.self, forKey: .status),
           let decodedStatus = ServiceRequestStatus(rawValue: statusString) {
            status = decodedStatus
        } else {
            status = .inProgress
        }

        // Type with fallback to .individual
        if let typeString = try? container.decode(String.self, forKey: .type),
           let decodedType = ServiceRequestType(rawValue: typeString) {
            type = decodedType
        } else {
            type = .individual
        }

        // DEFENSIVE: area field - default to 0.0 if null or missing
        if let decodedArea = try? container.decodeIfPresent(Double.self, forKey: .area) {
            area = decodedArea
        } else {
            area = 0.0
        }

        // String fields with fallbacks
        timeSlot = (try? container.decode(String.self, forKey: .timeSlot)) ?? "Morning"
        timePeriod = (try? container.decode(String.self, forKey: .timePeriod)) ?? ""
        location = (try? container.decode(String.self, forKey: .location)) ?? ""

        // Optional joined user - handle both UUID and String formats
        if let joinedUUID = try? container.decodeIfPresent(UUID.self, forKey: .joinedUser) {
            joinedUser = joinedUUID
        } else if let joinedString = try? container.decodeIfPresent(String.self, forKey: .joinedUser),
                  let joinedUUID = UUID(uuidString: joinedString) {
            joinedUser = joinedUUID
        } else {
            joinedUser = nil
        }
    }

    // MARK: - Flexible Date Decoder Helper
    private static func decodeFlexibleDate(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Date? {
        // Try decoding as Date first
        if let date = try? container.decode(Date.self, forKey: key) {
            return date
        }

        // Try decoding as String and parse manually
        // Note: try? with decodeIfPresent flattens to String? in Swift 5.7+
        guard let dateStr = try? container.decodeIfPresent(String.self, forKey: key) else {
            return nil
        }

        // Format 1: "yyyy-MM-dd'T'HH:mm:ss"
        let simpleFormatter = DateFormatter()
        simpleFormatter.locale = Locale(identifier: "en_US_POSIX")
        simpleFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        simpleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = simpleFormatter.date(from: dateStr) {
            return date
        }

        // Format 2: "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        simpleFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        if let date = simpleFormatter.date(from: dateStr) {
            return date
        }

        // Format 3: ISO8601 with timezone
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = iso8601Formatter.date(from: dateStr) {
            return date
        }

        // Format 4: ISO8601 without fractional seconds
        iso8601Formatter.formatOptions = [.withInternetDateTime]
        if let date = iso8601Formatter.date(from: dateStr) {
            return date
        }

        // Format 5: Simple date "yyyy-MM-dd"
        simpleFormatter.dateFormat = "yyyy-MM-dd"
        if let date = simpleFormatter.date(from: dateStr) {
            return date
        }

        return nil
    }
}

// MARK: - ServiceRequestStatus Enum
enum ServiceRequestStatus: String, Codable, CaseIterable {
    case inProgress = "inProgress"
    case completed = "completed"
    case cancelled = "cancelled"
    case pending = "pending"

    var displayName: String {
        switch self {
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        case .cancelled: return "Cancelled"
        case .pending: return "Pending"
        }
    }

    var iconName: String {
        switch self {
        case .inProgress: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .cancelled: return "xmark.circle.fill"
        case .pending: return "clock.fill"
        }
    }
}

// MARK: - ServiceRequestType Enum
enum ServiceRequestType: String, Codable, CaseIterable {
    case individual = "individual"
    case coequip = "coequip"

    var displayName: String {
        switch self {
        case .individual: return "Individual"
        case .coequip: return "Co-Equip"
        }
    }
}

// MARK: - ServiceRequest DTO for Supabase
struct ServiceRequestDTO: Codable {
    let id: UUID
    let farmerId: UUID
    let equipmentName: String
    let amount: Double
    let date: Date
    let status: String
    let type: String
    let area: Double
    let timeSlot: String
    let timePeriod: String
    let location: String
    let joinedUser: String?

    enum CodingKeys: String, CodingKey {
        case id
        case farmerId = "farmerid"
        case equipmentName = "equipmentname"
        case amount
        case date
        case status
        case type
        case area
        case timeSlot = "timeslot"
        case timePeriod = "timeperiod"
        case location
        case joinedUser = "joineduser"
    }

    // Convert from domain model
    init(from serviceRequest: ServiceRequest) {
        self.id = serviceRequest.id
        self.farmerId = serviceRequest.farmerId
        self.equipmentName = serviceRequest.equipmentName
        self.amount = serviceRequest.amount
        self.date = serviceRequest.date
        self.status = serviceRequest.status.rawValue
        self.type = serviceRequest.type.rawValue
        self.area = serviceRequest.area
        self.timeSlot = serviceRequest.timeSlot
        self.timePeriod = serviceRequest.timePeriod
        self.location = serviceRequest.location
        self.joinedUser = serviceRequest.joinedUser?.uuidString
    }
}

// MARK: - Notification Extension for Service Requests
extension Notification.Name {
    static let serviceRequestsUpdated = Notification.Name("serviceRequestsUpdated")
    static let activeJobsUpdated = Notification.Name("activeJobsUpdated")
}
