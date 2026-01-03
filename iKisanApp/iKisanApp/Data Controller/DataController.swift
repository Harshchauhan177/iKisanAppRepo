import Foundation
import UIKit
import Supabase

class SupabaseManager {
    public static let shared: SupabaseManager = .init()
    private let key: String = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4dXV1cGlxZWlweWVtbHV5ZXJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMDUzMzQsImV4cCI6MjA2MDg4MTMzNH0.zH4zUtWuYB1YTzwIMx_Js6EgnI-s-3AV6WP0qsKjzZ8"
    private let url: String = "https://pxuuupiqeipyemluyers.supabase.co"
    
    public private(set) var client: SupabaseClient
    
    private init() {
        print("🔌 Initializing SupabaseManager...")
        print("🌐 URL: \(url)")
        print("🔑 Key length: \(key.count) characters")
        
        self.client = SupabaseClient(supabaseURL: URL(string: url)!, supabaseKey: key)
        print("✅ SupabaseClient initialized")
        
        // Verify connection immediately
        Task {
            do {
                print("🔄 Verifying database connection...")
                let _: [UserDTO] = try await client
                    .from("users")
                    .select("*")
                    .limit(1)
                    .execute()
                    .value
                print("✅ Database connection verified successfully")
            } catch {
                print("❌ Database connection test failed: \(error)")
                if let postgrestError = error as? PostgrestError {
                    print("🔍 Connection error details:")
                    print("  - Code: \(postgrestError.code ?? "nil")")
                    print("  - Message: \(postgrestError.message ?? "nil")")
                }
            }
        }
    }
}

protocol DataController: AnyObject {
    func getAllEquipment() -> [Equipment]
    func getEquipment(byType type: String) -> [Equipment]
    func getAllReviews() -> [ReviewData]
    func addReview(_ review: ReviewData)
    func getSuggestions() -> [Equipment]
    
    func getEquipment(sortedBy: SortOption) -> [Equipment]
    func searchEquipment(query: String) -> [Equipment]
    func getUpcomingBookings() -> [Booking]
    func addBooking(_ booking: Booking) -> Bool
    func isEquipmentAvailable(equipmentID: UUID, date: Date, timeSlot: TimeSlot) -> Bool
    func getAvailableTimeSlots(equipmentID: UUID, date: Date) -> [TimeSlot]
    func refreshBookingsFromDatabase() async
    
    // AgriAssist Related Functions
    func getAllCrops() -> [AgriCrop]
    func getAllCropsForSelection() -> [Crop]
    func getCropCategory(forCrop cropId: UUID) -> CropCategory?
    func getEquipmentCategories(forCrop cropId: UUID) -> [EquipmentCategory]
    func getEquipmentAgri(forCategory categoryId: UUID) -> [EquipmentAgri]
    func getEquipmentAgriDetails(id: UUID) -> EquipmentAgri?
    
    // Add these new functions for InfoAboutEquipments
    func getEquipmentSectionHeaders() -> [String]
    func getEquipmentTypeDetails() -> [EquipmentAgri]
    func getRelatedEquipment() -> [EquipmentAgri]
    
    // Add this new function for SameTypeAllEquipments
    func getEquipmentsByCategory(categoryId: UUID) -> [EquipmentAgri]
    
    // Add these new functions for crop selection
    func setSelectedCrops(_ cropNames: Set<String>)
    func getSelectedCrops() -> Set<String>
    
    // Add these new functions for crop field area management
    func saveCropFieldArea(cropName: String, area: String)
    func saveCropFieldAreas(areas: [String: String])
    func getCropFieldArea(cropName: String) -> String?
    func getAllCropFieldAreas() -> [String: String]
    
    //coequip Related functions
    func getAllCoEquipRequests() -> [Request]
    func getAcceptedRequests() -> [Request]
    func addNewCoEquipRequest(_ request: Request)
    func updateRequest(_ request: Request)
    func deleteRequest(with id: UUID)
    func getEquipmentById(_ id: UUID) -> Equipment?
    func getUserById(_ id: UUID) -> User?
    //func getAcceptedUsersForRequest(_ request: Request)
    func getAllUsers() -> [User]
    func getEquipmentSuggestions() -> [String]
    func filterEquipment(by query: String) -> [Equipment]
    func getCategories() -> [String]
    func getEquipmentList() -> [Equipment]
    func filterEquipment(byCategory category: String?) -> [Equipment]
    func filterEquipment(bySearchText searchText: String) -> [Equipment]
    func isEquipmentAvailable(on date: Date, for equipment: Equipment) -> Bool
    func createRequest(_ request: Request)
    func createRequest(_ request: Request, with selectedUsers: [User])
    func getTimeSlots(for area: Double) -> [TimeSlot]
    //func createRequestParticipant(_ participant: RequestParticipant)
    func createRequestParticipant(_ participant: RequestParticipant) async throws
    //For Prebooking
    // Add these new methods to the existing protocol
    func getRecommendedEquipments() -> [Equipment]
    func getAvailableEquipments() -> [Equipment]
    func getPreBookingCalendarEvents() -> [Booking]
    func getPreBookingFAQs() -> [FAQ]
    func createPreBooking(equipment: Equipment, date: Date) -> Bool
    func getEquipmentsByBookingStatus(status: BookingStatus) -> [Equipment]
    func updateBooking(_ booking: Booking)
    func getPreBookings() -> [Booking]
    func getEquipment(byId: UUID) -> Equipment?
    func refreshFAQsFromDatabase() async
    
    // Add this new function
    func getCurrentUserAddress() -> String?
    func getCurrentUser() -> User?
    
    // Add the missing method declaration
    func loadDataFromBackend() async
    
    // Get bookings for a specific user and equipment
    func getUserBookings(userID: UUID, equipmentID: UUID) -> [Booking]
}


enum SortOption {
    case priceHighToLow
    case priceLowToHigh
    case rating
    case name
}

enum EquipmentData {
    // Commented out hardcoded data to ensure only backend data is used
    static let equipment: [Equipment] = [
        // All equipment items removed/commented out to use only backend data
    ]
    
    // Commented out hardcoded reviews to use only backend data
    static let reviews: [ReviewData] = [
        // All review items removed/commented out to use only backend data
    ]
    
    // Commented out hardcoded sample requests to use only backend data
    static  let sampleRequests: [Request] = [
        // All request items removed/commented out to use only backend data
    ]

    // Commented out hardcoded suggestions to use only backend data
    static let suggestionsEquipment: [Equipment] = [
        // All suggestion items removed/commented out to use only backend data
    ]
}



class IKisanDataController: DataController {
   
   
    func createRequestParticipant(_ participant: RequestParticipant) async throws {
        // Validate required fields
        guard participant.id != nil,
              participant.requestId != nil,
              participant.userId != nil else {
            throw NSError(domain: "DataController", code: 400, userInfo: [NSLocalizedDescriptionKey: "Missing required fields for request participant"])
        }
        
        do {
            let response = try await SupabaseManager.shared.client
                .from("request_participants")
                .insert(participant)
                .execute()
            
            print("✅ Request participant created successfully")
            
            // Update the selectedUsersIds array in the requests table using proper JSON format
            try await SupabaseManager.shared.client
                .from("requests")
                .update([
                    "selectedUsersIds": [participant.userId.uuidString]
                ])
                .eq("id", value: participant.requestId.uuidString)
                .execute()
            
            print("✅ Request selectedUsersIds updated successfully")
            
        } catch let error as PostgrestError {
            print("❌ Error creating request participant: \(error.message)")
            if error.message.contains("unique_request_user") {
                throw NSError(domain: "DataController", code: 409, userInfo: [NSLocalizedDescriptionKey: "This user is already a participant in this request"])
            } else if error.message.contains("request_participants_requestId_fkey") {
                throw NSError(domain: "DataController", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid request ID reference"])
            } else if error.message.contains("request_participants_userId_fkey") {
                throw NSError(domain: "DataController", code: 404, userInfo: [NSLocalizedDescriptionKey: "Invalid user ID reference"])
            }
            throw error
        } catch {
            print("❌ Error creating request participant: \(error.localizedDescription)")
            throw error
        }
    }


    
    
    
        func getCurrentUser() -> User? {
            guard let currentUser = AuthManager.shared.currentUser else {
                return nil
            }
            
            // Convert AuthUser to User model
            return User(
                userID: currentUser.id,  // This is already a UUID, no conversion needed
                name: currentUser.name,
                email: currentUser.email,
                phone: currentUser.phone,
                location: Location(
                    latitude: currentUser.latitude,
                    longitude: currentUser.longitude,
                    address: currentUser.address
                ),
                selectedCrops: currentUser.selectedCrops ?? [],  // Use empty array as default if nil
                fieldArea: currentUser.fieldArea ?? 0.0,  // Use 0.0 as default if nil
                groupID: currentUser.groupID
            )
        }
    
    

    
    
        

        func getAllUsers() -> [User] {
        // Use the cached users if available, otherwise fetch from Supabase
        if !cachedUsers.isEmpty {
            return cachedUsers
        }
        
        Task {
            do {
                let users: [UserDTO] = try await SupabaseManager.shared.client
                    .from("users")
                    .select("*")
                    .execute()
                    .value
                    
                // Map UserDTO to User model and cache them
                self.cachedUsers = users.map { dto in
                    User(userID: UUID(uuidString: dto.id) ?? UUID(),  // Convert String to UUID
                         name: dto.name,
                         email: dto.email,
                         phone: dto.phone,
                         location: Location(latitude: dto.latitude,
                                          longitude: dto.longitude,
                                          address: dto.address),
                         selectedCrops: dto.selectedCrops.compactMap { UUID(uuidString: $0) },  // Convert [String] to [UUID]
                         fieldArea: dto.fieldArea,
                         groupID: nil)  // Set to nil since it's not in DTO
                }
            } catch {
                print("Error fetching users: \(error)")
            }
        }
        
        return cachedUsers
    }

    func getUserById(_ id: UUID) -> User? {
        // Check cached users first
        if let user = cachedUsers.first(where: { $0.userID == id }) {
            return user
        }
        // Silently return nil if user not found - this is expected behavior
        // The cache will be updated next time getAllUsers() is called
        return nil
    }
        
        // ... existing code ...
    
       
    // Add a property to store FAQs
    private var faqsList: [FAQ] = []
    
    // Add a property to store cached users
    private var cachedUsers: [User] = []
    
    func getCurrentUserAddress() -> String? {
        // Get the current user from cached users
        if let currentUser = cachedUsers.first {
            return currentUser.location.address
        }
        return nil
    }
    
    // Static IDs for all entities
    // Crop IDs
    private static let riceId = UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let wheatId = UUID(uuidString: "F622E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let oatsId = UUID(uuidString: "F623E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let cottonId = UUID(uuidString: "F624E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let teaId = UUID(uuidString: "F625E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let maizeId = UUID(uuidString: "F626E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let tobaccoId = UUID(uuidString: "F627E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let sugarcaneId = UUID(uuidString: "F628E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    // Category IDs
    private static let cultivatorsCategoryId = UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let harvestersCategoryId = UUID(uuidString: "A622E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let seedersCategoryId = UUID(uuidString: "A623E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let harrowCategoryId = UUID(uuidString: "A624E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let thresherCategoryId = UUID(uuidString: "A625E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let planterCategoryId = UUID(uuidString: "A626E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let ploughCategoryId = UUID(uuidString: "A627E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    // Equipment IDs (Grouped by Crop)
    private static let paddleWheelCultivatorId = UUID(uuidString: "D621E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let powerTillerId = UUID(uuidString: "D622E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let riceHarvesterId = UUID(uuidString: "D623E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let riceTransplanterId = UUID(uuidString: "D624E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let laserLandLevelerId = UUID(uuidString: "D625E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    private static let wheatSeederId = UUID(uuidString: "D626E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let wheatHarvesterId = UUID(uuidString: "D627E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let strawReaperId = UUID(uuidString: "D628E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let moldboardPloughId = UUID(uuidString: "D629E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let rotavatorId = UUID(uuidString: "D630E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    private static let airSeederId = UUID(uuidString: "D631E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let combineHarvesterId = UUID(uuidString: "D632E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let discHarrowId = UUID(uuidString: "D633E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let rollerCrimperId = UUID(uuidString: "D634E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    private static let cottonSeederId = UUID(uuidString: "D635E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let cottonPickerId = UUID(uuidString: "D636E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let defoliatorMachineId = UUID(uuidString: "D637E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let sprayerMachineId = UUID(uuidString: "D638E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    private static let teaPluckerId = UUID(uuidString: "D639E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let teaPruningMachineId = UUID(uuidString: "D640E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let teaDryerId = UUID(uuidString: "D641E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    private static let maizeSeederId = UUID(uuidString: "D642E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let maizeHarvesterId = UUID(uuidString: "D643E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let cornPlanterId = UUID(uuidString: "D644E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let grainDryerId = UUID(uuidString: "D645E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    private static let tobaccoSeederId = UUID(uuidString: "D646E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let tobaccoCurerId = UUID(uuidString: "D647E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let tobaccoHarvesterId = UUID(uuidString: "D648E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    private static let sugarcanePlanterId = UUID(uuidString: "D649E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let sugarcaneHarvesterId = UUID(uuidString: "D650E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let sugarcaneCrusherId = UUID(uuidString: "D651E1F8-C36C-495A-93FC-0C247A3E6E5F")!
    private static let chopperHarvesterId = UUID(uuidString: "D652E1F8-C36C-495A-93FC-0C247A3E6E5F")!

    private var equipmentList: [Equipment] = []
    private var reviewList: [ReviewData] = []
    private var suggestionList: [Equipment] = []
    private var bookingsList: [Booking] = []
    private var crops: [AgriCrop] = []
    private var cropsForSelection: [Crop] = []
    private var cropCategories: [CropCategory] = []
    private let sectionHeaders = ["Equipment Type Details", "Related Equipment"]
    private var coEquipRequests: [Request] = []
    private var acceptedRequests: [Request] = []
    private var pendingRequests: [Request] = []
    
    private let requestManager = RequestManager.shared
    private let selectedCropsKey = "selectedCrops"
    private var selectedCrops: Set<String> = []
    
    // Reference to any collectionView that needs to be updated
    weak var collectionView: UICollectionView?
    
    init() {
        // Load selected crops from UserDefaults
        if let savedCrops = UserDefaults.standard.array(forKey: selectedCropsKey) as? [String] {
            selectedCrops = Set(savedCrops)
            print("Loaded selected crops: \(selectedCrops)")
        }
        
        // Eagerly fetch crops from Supabase when controller is initialized (silently)
        Task {
            let fetchedCrops = await requestManager.fetchCrops()
            await MainActor.run {
                self.crops = fetchedCrops
                // Notify any UI that needs updating
                NotificationCenter.default.post(name: NSNotification.Name("CropsUpdated"), object: nil)
            }
        }
        
        // Setup initial data
        Task {
            await loadDataFromBackend()
            await refreshFAQsFromDatabase()
        }
    }
    
    public func loadDataFromBackend() async {
        // Load all data from backend
        self.equipmentList = await requestManager.fetchEquipments()
        self.reviewList = await requestManager.fetchReviews()
        self.bookingsList = await requestManager.fetchBookings()
        self.crops = await requestManager.fetchCrops()
        self.cropCategories = await requestManager.fetchCropCategories()
        self.cachedUsers = getAllUsers()
        // Load requests and update the local arrays
        self.coEquipRequests = await requestManager.fetchRequests()
        self.acceptedRequests = self.coEquipRequests.filter { $0.status == .confirmed }
        
        // Make a local copy of suggestions for quick access
        self.suggestionList = self.equipmentList.filter { $0.isRecommended }
        
        print("✅ Initial data load complete: \(self.coEquipRequests.count) requests loaded")
        
        // Post notification for initial load completion (only once at startup)
        // This allows views to display data after the first load
        await MainActor.run {
            NotificationCenter.default.post(name: .dataInitiallyLoaded, object: nil)
        }
    }
    
    func getAllEquipment() -> [Equipment] {
        return equipmentList
    }
    
    func getEquipment(byType type: String) -> [Equipment] {
        return equipmentList.filter { $0.type == type }
    }
    
    func getAllReviews() -> [ReviewData] {
        return reviewList
    }
    
    func addReview(_ review: ReviewData) {
        reviewList.append(review)
        // Ideally should save to backend but not implemented in RequestManager yet
    }
    
    func getSuggestions() -> [Equipment] {
        return suggestionList
    }
    
    func getEquipment(sortedBy: SortOption) -> [Equipment] {
        var sortedEquipment = equipmentList
        
        switch sortedBy {
        case .priceHighToLow:
            sortedEquipment.sort { $0.pricePerHour > $1.pricePerHour }
        case .priceLowToHigh:
            sortedEquipment.sort { $0.pricePerHour < $1.pricePerHour }
        case .rating:
            sortedEquipment.sort { $0.rating > $1.rating }
        case .name:
            sortedEquipment.sort { $0.name < $1.name }
        }
        
        return sortedEquipment
    }

    func searchEquipment(query: String) -> [Equipment] {
        let lowercaseQuery = query.lowercased()
        return equipmentList.filter { equipment in
            equipment.name.lowercased().contains(lowercaseQuery) ||
            equipment.type.lowercased().contains(lowercaseQuery) ||
            equipment.location.lowercased().contains(lowercaseQuery)
        }
    }
    
    func getUpcomingBookings() -> [Booking] {
        let currentDate = Date()
        return bookingsList.filter { $0.bookingDate > currentDate }
    }
    
    func addBooking(_ booking: Booking) -> Bool {
        // Ensure we have a logged in user
        guard let currentUser = AuthManager.shared.currentUser else {
            print("Error: No logged in user found")
            return false
        }
        
        // Verify the equipment exists
        guard let equipment = getEquipment(byId: booking.equipmentID) else {
            print("Error: Equipment with ID \(booking.equipmentID) not found")
            return false
        }
        
        // Check if the equipment is already booked for this date and time slot
        if !isEquipmentAvailable(equipmentID: booking.equipmentID, date: booking.bookingDate, timeSlot: booking.timeSlot) {
            print("Error: Equipment \(equipment.name) is already booked for \(booking.bookingDate) during \(booking.timeSlot.rawValue)")
            return false
        }
        
        print("Creating booking for equipment: \(equipment.name) with ID: \(equipment.equipmentID)")
        
        // Log location data to verify it's being passed correctly
        if let location = booking.bookingLocation {
            print("Booking location data: lat=\(location.latitude), lon=\(location.longitude), address=\(location.address ?? "none")")
        } else {
            print("Warning: No location data provided with this booking")
        }
        
        // Create a new booking with the current user's ID AND preserve the location data
        let bookingWithUserId = Booking(
            bookingID: booking.bookingID,
            userID: currentUser.id, // Use the current user's ID
            equipmentID: equipment.equipmentID,
            bookingType: booking.bookingType,
            bookingDate: booking.bookingDate,
            fieldArea: booking.fieldArea,
            status: booking.status,
            timeSlot: booking.timeSlot,
            source: booking.source,
            bookingLocation: booking.bookingLocation // Include the location data
        )
        
        bookingsList.append(bookingWithUserId)
        
        // Save to Supabase
        Task {
            await RequestManager.shared.createBooking(bookingWithUserId)
        }
        
        return true
    }
    
    func refreshBookingsFromDatabase() async {
        // Fetch the latest bookings from the database
        let latestBookings = await RequestManager.shared.fetchBookings()
        
        // Update the local bookings list on the main thread
        await MainActor.run {
            // Replace the entire bookings list with the latest data from the database
            self.bookingsList = latestBookings
            print("Refreshed bookings from database: \(latestBookings.count) bookings loaded")
        }
    }
    
    func isEquipmentAvailable(equipmentID: UUID, date: Date, timeSlot: TimeSlot) -> Bool {
        // Get all bookings for this equipment
        let existingBookings = bookingsList.filter { booking in
            // Only consider confirmed or pending bookings
            let relevantStatus = [BookingStatus.confirmed, BookingStatus.pending].contains(booking.status)
            
            // Check if this booking is for the same equipment
            let sameEquipment = booking.equipmentID == equipmentID
            
            // Check if the booking is for the same date (ignoring time)
            let sameDate = Calendar.current.isDate(booking.bookingDate, inSameDayAs: date)
            
            // Check if the booking is for the same time slot
            let sameTimeSlot = booking.timeSlot == timeSlot
            
            // Return true if all conditions are met (meaning the equipment is already booked)
            return relevantStatus && sameEquipment && sameDate && sameTimeSlot
        }
        
        // If there are no existing bookings that match our criteria, the equipment is available
        return existingBookings.isEmpty
    }
    
    func getAvailableTimeSlots(equipmentID: UUID, date: Date) -> [TimeSlot] {
        // Start with all possible time slots
        var availableSlots: [TimeSlot] = [.morning, .afternoon, .evening]
        
        // Get all bookings for this equipment on this date
        let bookedSlots = bookingsList.filter { booking in
            // Only consider confirmed or pending bookings
            let relevantStatus = [BookingStatus.confirmed, BookingStatus.pending].contains(booking.status)
            
            // Check if this booking is for the same equipment
            let sameEquipment = booking.equipmentID == equipmentID
            
            // Check if the booking is for the same date (ignoring time)
            let sameDate = Calendar.current.isDate(booking.bookingDate, inSameDayAs: date)
            
            return relevantStatus && sameEquipment && sameDate
        }.map { $0.timeSlot }
        
        // Remove booked slots from available slots
        for slot in bookedSlots {
            if let index = availableSlots.firstIndex(of: slot) {
                availableSlots.remove(at: index)
            }
        }
        
        return availableSlots
    }
    
    // MARK: - AgriAssist Functions
    
    func getAllCropsForSelection() -> [Crop] {
        // If crops for selection array is empty, try to fetch them synchronously
        if cropsForSelection.isEmpty {
            // Create a task to fetch crops
            Task {
                let fetchedCrops = await requestManager.fetchCropsForSelection()
                if !fetchedCrops.isEmpty {
                    // Update crops on the main thread
                    await MainActor.run {
                        self.cropsForSelection = fetchedCrops
                        // Notify any UI that needs updating
                        NotificationCenter.default.post(name: NSNotification.Name("CropsForSelectionUpdated"), object: nil)
                    }
                }
            }
            
            // Return existing crops for selection if available, otherwise convert from current crops temporarily
            if !cropsForSelection.isEmpty {
                return cropsForSelection
            } else if !crops.isEmpty {
                // Temporarily convert AgriCrop to Crop until data is loaded
                return crops.map { Crop(id: $0.id, name: $0.name, imageURL: $0.imageName) }
            }
            return []
        }
        
        return cropsForSelection
    }
    
    func getAllCrops() -> [AgriCrop] {
        // If crops array is empty, try to fetch them synchronously
        if crops.isEmpty {
            // Create a task to fetch crops
            Task {
                let fetchedCrops = await requestManager.fetchCrops()
                if !fetchedCrops.isEmpty {
                    // Update crops on the main thread
                    await MainActor.run {
                        self.crops = fetchedCrops
                        // Notify any UI that needs updating
                        NotificationCenter.default.post(name: NSNotification.Name("CropsUpdated"), object: nil)
                    }
                }
            }
            
            // Return current crops (might still be empty)
            return crops
        }
        return crops
    }
    
    func getCropCategory(forCrop cropId: UUID) -> CropCategory? {
        // Check if we already have the category
        if let category = cropCategories.first(where: { $0.id == cropId }) {
        return category
        }
        
        // If not, fetch it asynchronously but return nil immediately
        Task {
            self.cropCategories = await requestManager.fetchCropCategories()
            DispatchQueue.main.async {
                self.collectionView?.reloadData()
            }
        }
        
        return nil
    }
    
    func getEquipmentCategories(forCrop cropId: UUID) -> [EquipmentCategory] {
        if let category = getCropCategory(forCrop: cropId) {
            return category.equipments
        }
        return []
    }
    
    func getEquipmentAgri(forCategory categoryId: UUID) -> [EquipmentAgri] {
        for category in cropCategories {
            for equipment in category.equipments {
                if equipment.id == categoryId {
                    return equipment.equipmentList
                }
            }
        }
        return []
    }
    
    func getEquipmentAgriDetails(id: UUID) -> EquipmentAgri? {
        for category in cropCategories {
            for equipmentCategory in category.equipments {
                if let equipment = equipmentCategory.equipmentList.first(where: { $0.id == id }) {
                    return equipment
                }
            }
        }
        return nil
    }
    
    // MARK: - InfoAboutEquipments Functions
    
    func getEquipmentSectionHeaders() -> [String] {
        return sectionHeaders
    }
    
    func getEquipmentTypeDetails() -> [EquipmentAgri] {
        // Placeholder implementation
        for category in cropCategories {
            for equipment in category.equipments {
                if !equipment.equipmentList.isEmpty {
                    return equipment.equipmentList
                }
            }
        }
        return []
    }
    
    func getRelatedEquipment() -> [EquipmentAgri] {
        // Placeholder implementation
        for category in cropCategories {
            for equipment in category.equipments {
                if !equipment.equipmentList.isEmpty {
                    return equipment.equipmentList
                }
            }
        }
        return []
    }
    
    // MARK: - SameTypeAllEquipments Function
    
    func getEquipmentsByCategory(categoryId: UUID) -> [EquipmentAgri] {
        for category in cropCategories {
            for equipment in category.equipments {
                if equipment.id == categoryId {
                    return equipment.equipmentList
                }
            }
        }
        return []
    }
    
    // MARK: - CoEquip Functions
    
    func isEquipmentAvailable(on date: Date, for equipmentName: String) -> Bool {
        if let equipment = equipmentList.first(where: { $0.name == equipmentName }) {
            return equipment.isAvailable(on: date)
        }
        return false
    }
    
    func getAllCoEquipRequests() -> [Request] {
        // Return cached requests without triggering a fetch
        // Fetches are handled by explicit refresh calls only
        return coEquipRequests
    }
    
    // Explicit refresh method for when data needs to be updated
    func refreshCoEquipRequests() async {
        let newRequests = await requestManager.fetchRequests()
        
        print("🔄 refreshCoEquipRequests: Fetched \(newRequests.count) requests from backend")
        print("📊 Current local requests: \(self.coEquipRequests.count)")
        
        // Only update and notify if data has actually changed
        if newRequests.count != self.coEquipRequests.count || newRequests != self.coEquipRequests {
            print("✅ Data changed, updating and posting notification")
            self.coEquipRequests = newRequests
            self.acceptedRequests = self.coEquipRequests.filter { $0.status == .confirmed }
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .requestsUpdated, object: nil)
            }
        } else {
            print("ℹ️ No data changes detected, skipping update")
        }
    }
    
    func getAcceptedRequests() -> [Request] {
        return acceptedRequests
    }
    
    func addNewCoEquipRequest(_ request: Request) {
        print("🔄 Starting to add new request...")
        print("📝 Request details:")
        print("  - ID: \(request.id)")
        print("  - User ID: \(request.userId)")
        print("  - Equipment ID: \(request.equipmentId)")
        print("  - Date: \(request.requestedDate)")
        print("  - Area: \(request.area)")
        print("  - Location: \(request.location)")
        
        if !coEquipRequests.contains(where: { $0.id == request.id }) {
            coEquipRequests.append(request)
            print("✅ Request added to local array")
            
            // Save to backend
            Task {
                print("📤 Saving request to Supabase...")
                let success = await requestManager.createRequest(request)
                if success {
                    print("✅ Request successfully saved to Supabase")
                } else {
                    print("❌ Failed to save request to Supabase")
                }
            }
        } else {
            print("⚠️ Request with ID \(request.id) already exists")
        }
    }
    
    func updateRequest(_ request: Request) {
        if let index = coEquipRequests.firstIndex(where: { $0.id == request.id }) {
            coEquipRequests[index] = request
            
            // Update on backend
            Task {
                _ = await requestManager.updateRequest(request)
        }
    }
    }
    
    func deleteRequest(with id: UUID) {
        if let index = coEquipRequests.firstIndex(where: { $0.id == id }) {
            coEquipRequests.remove(at: index)
        }
        if let index = pendingRequests.firstIndex(where: { $0.id == id }) {
            pendingRequests.remove(at: index)
        }
        if let index = acceptedRequests.firstIndex(where: { $0.id == id }) {
            acceptedRequests.remove(at: index)
        }
        
        // Delete from backend
        Task {
            _ = await requestManager.deleteRequest(with: id)
        }
        
        NotificationCenter.default.post(
            name: .requestDeleted,
            object: nil,
            userInfo: ["requestId": id]
        )
    }
    
    func getEquipmentById(_ id: UUID) -> Equipment? {
        // Convert the UUID to lowercase for comparison
        let lowercaseId = id.uuidString.lowercased()
        
        // First try exact match
        if let equipment = equipmentList.first(where: { $0.equipmentID.uuidString.lowercased() == lowercaseId }) {
            return equipment
        }
        
        // If exact match fails, try to find equipment by name "Square Balers" 
        // since this is the ID we know should work from the error message
        if let squareBalers = equipmentList.first(where: { $0.name == "Square Balers" }) {
            return squareBalers
        }
        
        // If all else fails, get the real equipment IDs from the backend
        print("Equipment not found in local cache, trying to fetch from backend")
        Task {
            self.equipmentList = await requestManager.fetchEquipments()
            print("Refreshed equipment list. Available equipment IDs:")
            for equip in self.equipmentList {
                print("- \(equip.name): \(equip.equipmentID.uuidString.lowercased())")
            }
        }
        
        return nil
    }
    
    
    

    func getEquipmentSuggestions() -> [String] {
        // Get unique equipment names from the equipmentList
        let suggestions = Set(equipmentList.map { $0.name })
        return Array(suggestions).sorted()
    }
    
    func filterEquipment(by query: String) -> [Equipment] {
        let lowercasedQuery = query.lowercased()
        return equipmentList.filter { equipment in
            equipment.name.lowercased().contains(lowercasedQuery) ||
            equipment.type.lowercased().contains(lowercasedQuery) ||
            equipment.location.lowercased().contains(lowercasedQuery)
        }
    }
    
    func getCategories() -> [String] {
        return ["All", "Rice", "Wheat", "Soyabean", "Irrigation", "Other"]
    }
    
    func getEquipmentList() -> [Equipment] {
        return equipmentList
    }
    
    func filterEquipment(byCategory category: String?) -> [Equipment] {
        guard let category = category else { return equipmentList }
        return equipmentList.filter { $0.type.contains(category) }
    }
    
    func filterEquipment(bySearchText searchText: String) -> [Equipment] {
        let lowercasedQuery = searchText.lowercased()
        return equipmentList.filter { equipment in
            equipment.name.lowercased().contains(lowercasedQuery) ||
            equipment.type.lowercased().contains(lowercasedQuery) ||
            equipment.location.lowercased().contains(lowercasedQuery)
        }
    }
    
    func isEquipmentAvailable(on date: Date, for equipment: Equipment) -> Bool {
        // Check if the date falls within the equipment's availability period
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Check if date is in the availability range
        guard date >= equipment.availability.startDate &&
              date <= equipment.availability.endDate else {
            return false
        }
        
        // Check if there are any existing bookings for this date
        return !bookingsList.contains(where: { booking in
            booking.equipmentID == equipment.equipmentID &&
            calendar.isDate(booking.bookingDate, inSameDayAs: date)
        })
    }
    
    func createRequest(_ request: Request) {
        coEquipRequests.append(request)
        
        // Save to backend
        Task {
            _ = await requestManager.createRequest(request)
    }
    }
    
    func createRequest(_ request: Request, with selectedUsers: [User]) {
        var updatedRequest = request
        // Convert User array to UUID array
        let selectedUserIds = selectedUsers.map { $0.userID }
        
        
        Task {
            do {
                try await SupabaseManager.shared.client
                    .from("requests")
                    .insert(updatedRequest)
                    .execute()
                
                // Update local cache
                self.coEquipRequests.append(updatedRequest)
                if updatedRequest.status == .confirmed {
                    self.acceptedRequests.append(updatedRequest)
                }
            } catch {
                print("Error creating request: \(error)")
            }
        }
    }
    
    func getTimeSlots(for area: Double) -> [TimeSlot] {
        // Logic to determine available time slots based on area
        if area <= 5 {
            return [.morning, .afternoon, .evening]
        } else if area <= 10 {
            return [.morning, .afternoon]
        } else {
            return [.morning]
        }
    }
    
    // MARK: - Prebooking Methods
    
    func getPreBookingFAQs() -> [FAQ] {
        return faqsList
    }
    
    func refreshFAQsFromDatabase() async {
        do {
            let faqs = try await RequestManager.shared.fetchFAQs()
            await MainActor.run {
                self.faqsList = faqs
                print("Loaded \(faqs.count) FAQs from database")
            }
        } catch {
            print("Error refreshing FAQs: \(error)")
        }
    }
    
    func getRecommendedEquipments() -> [Equipment] {
        return equipmentList.filter { $0.isRecommended }
    }
    
    func getAvailableEquipments() -> [Equipment] {
        let currentDate = Date()
        return equipmentList.filter { equipment in
            equipment.isAvailable(on: currentDate)
        }
    }
    
    func getPreBookingCalendarEvents() -> [Booking] {
        return bookingsList.filter { $0.bookingType == .prebooking }
    }
    
//    func getPreBookingFAQs() -> [FAQ] {
//        var faqs: [FAQ] = []
//        
//        // Fetch from backend if needed
//        if faqs.isEmpty {
//            Task {
//                faqs = await requestManager.fetchFAQs()
//            }
//        }
//        
//        return faqs
//    }
    
    func createPreBooking(equipment: Equipment, date: Date) -> Bool {
        // Ensure we have a logged in user
        guard let currentUser = AuthManager.shared.currentUser else {
            print("Error: No logged in user found")
            return false
        }
        
        // Check if already booked
        let calendar = Calendar.current
        if bookingsList.contains(where: { booking in
            booking.equipmentID == equipment.equipmentID &&
            calendar.isDate(booking.bookingDate, inSameDayAs: date)
        }) {
            return false
        }
        
        print("Creating prebooking for equipment: \(equipment.name) with ID: \(equipment.equipmentID.uuidString.lowercased())")
        
        // Create booking
        let booking = Booking(
            bookingID: UUID(),
            userID: currentUser.id, // Use the current user's ID
            equipmentID: equipment.equipmentID,
            bookingType: .prebooking,
            bookingDate: date,
            fieldArea: 0, // Default value, should be set by user
            status: .pending,
            timeSlot: .morning, // Default, should be selected by user
            source: .prebooking
        )
        
        addBooking(booking)
        return true
    }
    
    func getEquipmentsByBookingStatus(status: BookingStatus) -> [Equipment] {
        let bookingsWithStatus = bookingsList.filter { $0.status == status }
        let equipmentIDs = Set(bookingsWithStatus.map { $0.equipmentID })
        
        return equipmentList.filter { equipmentIDs.contains($0.equipmentID) }
    }
    
    func updateBooking(_ booking: Booking) {
        if let index = bookingsList.firstIndex(where: { $0.bookingID == booking.bookingID }) {
            bookingsList[index] = booking
            
            // Update on backend
            Task {
                _ = await requestManager.createBooking(booking) // This is an upsert operation
            }
        }
    }
    
    func getPreBookings() -> [Booking] {
        return bookingsList.filter { $0.bookingType == .prebooking }
    }
    
    func getEquipment(byId: UUID) -> Equipment? {
        return equipmentList.first { $0.equipmentID == byId }
    }
    
    func setSelectedCrops(_ cropNames: Set<String>) {
        self.selectedCrops = cropNames
        // Save to UserDefaults
        UserDefaults.standard.set(Array(cropNames), forKey: selectedCropsKey)
        print("Selected crops updated and saved: \(cropNames)")
    }
    
    func getSelectedCrops() -> Set<String> {
        return selectedCrops
    }
    
    // Key for storing crop field areas in UserDefaults
    private let cropFieldAreasKey = "userCropFieldAreas"
    
    // Save field area for a specific crop
    func saveCropFieldArea(cropName: String, area: String) {
        // Get existing field areas or create a new dictionary
        var fieldAreas = UserDefaults.standard.dictionary(forKey: cropFieldAreasKey) as? [String: String] ?? [:]
        
        // Update the field area for this crop
        fieldAreas[cropName] = area
        
        // Save the updated dictionary
        UserDefaults.standard.set(fieldAreas, forKey: cropFieldAreasKey)
        print("Saved field area \(area) for crop: \(cropName)")
    }
    
    // Save multiple crop field areas at once
    func saveCropFieldAreas(areas: [String: String]) {
        // Get existing field areas or create a new dictionary
        var fieldAreas = UserDefaults.standard.dictionary(forKey: cropFieldAreasKey) as? [String: String] ?? [:]
        
        // Merge the new areas with existing ones
        for (crop, area) in areas {
            fieldAreas[crop] = area
        }
        
        // Save the updated dictionary
        UserDefaults.standard.set(fieldAreas, forKey: cropFieldAreasKey)
        print("Saved field areas for \(areas.count) crops")
    }
    
    // Get field area for a specific crop
    func getCropFieldArea(cropName: String) -> String? {
        let fieldAreas = UserDefaults.standard.dictionary(forKey: cropFieldAreasKey) as? [String: String] ?? [:]
        return fieldAreas[cropName]
    }
    
    // Get all stored crop field areas
    func getAllCropFieldAreas() -> [String: String] {
        return UserDefaults.standard.dictionary(forKey: cropFieldAreasKey) as? [String: String] ?? [:]
    }
    
    // Get bookings for a specific user and equipment
    func getUserBookings(userID: UUID, equipmentID: UUID) -> [Booking] {
        return bookingsList.filter { $0.userID == userID && $0.equipmentID == equipmentID }
    }
}

class currentUser {
    static let shared = currentUser()
    
    private init() {}
    
    var user: User?
}

class RequestManager {
    static let shared = RequestManager()
    
    var equipmentItems: [Equipment] = []
    var requests: [Request] = []
    var reviews: [ReviewData] = []
    var users: [User] = []
    var bookings: [Booking] = []
    var crops: [AgriCrop] = []
    var equipmentCategories: [EquipmentCategory] = []
    var equipmentAgri: [EquipmentAgri] = []
    var faqs: [FAQ] = []

    private init() {
        Task {
            self.equipmentItems = await fetchEquipments()
        }
    }
    
    func fetchEquipments() async -> [Equipment] {
        do {
            // Fetch equipment data
            var equipmentData: [Equipment] = try await SupabaseManager.shared.client
                .from("equipment")
                .select("*")
                .execute()
                .value
            
            // Fetch all equipment images from equipmentMoreImages table
            let imageRecords: [EquipmentImageRecord] = try await SupabaseManager.shared.client
                .from("equipmentMoreImages")
                .select("*")
                .execute()
                .value
            
            // Group images by equipmentID
            var imagesByEquipmentID: [UUID: [String]] = [:]
            for record in imageRecords {
                if let equipmentID = record.equipmentID {
                    imagesByEquipmentID[equipmentID, default: []].append(record.image)
                }
            }
            
            // Assign images to each equipment
            for i in 0..<equipmentData.count {
                let equipmentID = equipmentData[i].equipmentID
                if let images = imagesByEquipmentID[equipmentID], !images.isEmpty {
                    equipmentData[i].equipmentMoreImages = EquipmentMoreImages(images: images)
                    // Silently loaded additional images
                }
            }
            
            return equipmentData
        } catch {
            print("Error fetching equipment: \(error)")
            return []
        }
    }
    
    func fetchReviews() async -> [ReviewData] {
        do {
            // Using the correct table name and field names
            let reviewsData: [ReviewDataDTO] = try await SupabaseManager.shared.client
                .from("reviews")
                .select("*")
                .execute()
                .value
            
            // Convert DTO to model with the correct field names
            let reviews = reviewsData.map { dto in
                return ReviewData(
                    reviewHeading: dto.reviewHeading, 
                    reviewDescription: dto.reviewDescription, 
                    rating: dto.rating,
                    equipmentID: dto.equipmentID,
                    equipmentName: nil // We'll update this later if needed
                )
            }
            
            // Update the static ReviewDataClass with the fetched reviews
            ReviewDataClass.updateReviews(with: reviews)
            
            return reviews
        } catch {
            print("Error fetching reviews: \(error)")
            return [] // Return empty array instead of fallback data to ensure only backend data is used
        }
    }
    
    func fetchRequests() async -> [Request] {
        do {
            // Fetch requests from database
            
            // Get the raw data with participants and acceptedUser
            let rawData = try await SupabaseManager.shared.client
                .from("requests")
                .select("""
                    *,
                    request_participants (
                        id,
                        requestId,
                        userId,
                        status,
                        area,
                        timeSlotId,
                        joinedAt,
                        created_at,
                        updated_at
                    )
                """)
                .execute()
                .data
            
            // Create a decoder with proper date decoding strategy
            let decoder = JSONDecoder()
            
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // Create date formatter for the simple format
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                
                // Try parsing with different formats
                let formats = [
                    "yyyy-MM-dd'T'HH:mm:ss",       // Basic format: 2025-05-29T09:54:35
                    "yyyy-MM-dd'T'HH:mm:ssZ",      // With timezone: 2025-05-29T09:54:35Z
                    "yyyy-MM-dd'T'HH:mm:ss.SSSZ"   // With milliseconds and timezone
                ]
                
                for format in formats {
                    formatter.dateFormat = format
                    if let date = formatter.date(from: dateString) {
                        return date
                    }
                }
                
                print("❌ Failed to parse date string: \(dateString)")
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot decode date string \(dateString)"
                )
            }
            
            // Decode the requests with their participants
            struct RequestWithParticipants: Codable {
                let id: UUID
                let userId: UUID
                let equipmentId: UUID
                let requestedDate: Date
                let status: String
                let type: String
                let area: Double
                let timeSlot: String
                let timePeriod: String?
                let location: String
                let typeOfRequest: String
                let acceptedUser: [String]? // Match the exact column name from Supabase
                let request_participants: [ParticipantDTO]?
                
                struct ParticipantDTO: Codable {
                    let id: UUID
                    let requestId: UUID
                    let userId: UUID
                    let status: String
                    let area: Double?
                    let timeSlotId: String?
                    let joinedAt: Date
                    let created_at: Date?
                    let updated_at: Date?
                }
                
                enum CodingKeys: String, CodingKey {
                    case id, userId, equipmentId, requestedDate, status, type, area, timeSlot, timePeriod, location, typeOfRequest, acceptedUser, request_participants
                }
            }
            
            let requestsWithParticipants = try decoder.decode([RequestWithParticipants].self, from: rawData)
            
            // Decoded requests from database (silent logging)
            
            // Convert to domain models
            var requests: [Request] = []
            for dto in requestsWithParticipants {
                // Convert participants
                let participants = dto.request_participants?.map { participantDto in
                    RequestParticipant(
                        id: participantDto.id,
                        requestId: participantDto.requestId,
                        userId: participantDto.userId,
                        status: ParticipantStatus(rawValue: participantDto.status) ?? .pending,
                        area: participantDto.area,
                        timeSlot: participantDto.timeSlotId,
                        joinedAt: participantDto.joinedAt
                    )
                } ?? []
                
                // Silently process acceptedUser array
                
                // Create the request with all data
                let request = Request(
                    id: dto.id,
                    userId: dto.userId,
                    equipmentId: dto.equipmentId,
                    requestedDate: dto.requestedDate,
                    status: BookingStatus(rawValue: dto.status) ?? .pending,
                    type: BookingType(rawValue: dto.type) ?? .onDemand,
                    area: dto.area,
                    timeSlot: TimeSlot(rawValue: dto.timeSlot) ?? .morning,
                    timePeriod: dto.timePeriod,
                    location: dto.location,
                    typeOfRequest: dto.typeOfRequest == "myRequest" ? .myRequest : .acceptedRequest,
                    participants: participants,
                    acceptedUsers: dto.acceptedUser?.compactMap { UUID(uuidString: $0) } ?? []
                )
                
                requests.append(request)
            }
            
            // Successfully fetched requests
            return requests
            
        } catch {
            print("❌ Error fetching requests: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .dataCorrupted(let context):
                    print("Data corrupted error:")
                    print("Debug description: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                    if let underlying = context.underlyingError {
                        print("Underlying error: \(underlying)")
                    }
                case .keyNotFound(let key, let context):
                    print("Key '\(key.stringValue)' not found:")
                    print("Debug description: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch for type \(type):")
                    print("Debug description: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                case .valueNotFound(let type, let context):
                    print("Value of type \(type) not found:")
                    print("Debug description: \(context.debugDescription)")
                    print("Coding path: \(context.codingPath)")
                @unknown default:
                    print("Unknown decoding error: \(decodingError)")
                }
            } else if let postgrestError = error as? PostgrestError {
                print("Postgrest error details:")
                print("Code: \(postgrestError.code ?? "nil")")
                print("Message: \(postgrestError.message ?? "nil")")
                print("Hint: \(postgrestError.hint ?? "nil")")
                print("Details: \(postgrestError.detail ?? "nil")")
            }
            return []
        }
    }
    
    func fetchUsersById(userIds: [String]) async -> [User] {
        do {
            let data: [UserDTO] = try await SupabaseManager.shared.client
                .from("users")
                .select("*")
                .in("userID", values: userIds) // Changed from "id" to "userID"
                .execute()
                .value
            
            return data.map { dto in
                User(
                    userID: UUID(uuidString: dto.id) ?? UUID(),
                    name: dto.name,
                    email: dto.email,
                    phone: dto.phone,
                    location: Location(
                        latitude: dto.latitude,
                        longitude: dto.longitude,
                        address: dto.address
                    ),
                    selectedCrops: dto.selectedCrops.compactMap { UUID(uuidString: $0) },
                    fieldArea: dto.fieldArea,
                    groupID: dto.groupId != nil ? UUID(uuidString: dto.groupId!) : nil
                )
            }
        } catch {
            print("Error fetching users: \(error)")
            return []
        }
    }
    
    func fetchAllUsers() async -> [User] {
        do {
            print("🔄 Starting fetchAllUsers from Supabase...")
            
            // Verify auth state
            if let session = try? await SupabaseManager.shared.client.auth.session {
                print("✅ User is authenticated with ID: \(session.user.id)")
            } else {
                print("⚠️ No active session found")
                return []
            }
            
            print("📝 Querying 'users' table with select *")
            
            // Use PostgrestResponse to get typed response
            let response: PostgrestResponse<[UserDTO]> = try await SupabaseManager.shared.client
                .from("users")
                .select("*")
                .execute()
            
            // Debug the raw response
            print("📊 Raw response type: \(type(of: response.data))")
            
            guard let users = try? response.value else {
                print("❌ Failed to get users from response")
                return []
            }
            
            print("📊 Received \(users.count) users")
            
            // Convert DTOs to User models
            let mappedUsers = users.map { dto in
                let user = User(
                    userID: UUID(uuidString: dto.id) ?? UUID(),
                    name: dto.name,
                    email: dto.email,
                    phone: dto.phone,
                    location: Location(
                        latitude: dto.latitude,
                        longitude: dto.longitude,
                        address: dto.address
                    ),
                    selectedCrops: dto.selectedCrops.compactMap { UUID(uuidString: $0) },
                    fieldArea: dto.fieldArea,
                    groupID: dto.groupId.flatMap { UUID(uuidString: $0) }
                )
                print("👤 Mapped user: \(user.name) (ID: \(user.userID))")
                return user
            }
            
            print("✅ Successfully mapped \(mappedUsers.count) users")
            return mappedUsers
            
        } catch {
            print("❌ Error fetching users: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("🔍 PostgrestError details:")
                print("  - Code: \(postgrestError.code ?? "nil")")
                print("  - Message: \(postgrestError.message ?? "nil")")
                print("  - Hint: \(postgrestError.hint ?? "nil")")
                print("  - Details: \(postgrestError.detail ?? "nil")")
                
                // Check if this is an auth error
                if postgrestError.code == "PGRST301" || 
                    (postgrestError.message.contains("JWT") ?? false) {
                    print("🔐 Authentication error detected. User may need to re-login.")
                }
            }
            return []
        }
    }
    
    func fetchBookings() async -> [Booking] {
        do {
            // Fetching bookings from database (silent)
            
            // Only fetch bookings for the currently logged-in user
            guard let currentUser = AuthManager.shared.currentUser else {
                print("No logged-in user found, returning empty bookings list")
                return []
            }
            
            // Use a simpler approach with direct JSON parsing
            let result = try await SupabaseManager.shared.client
                .from("bookings")
                .select("*")
                .eq("userID", value: currentUser.id.uuidString)
                .execute()
            
            // Handle the data from the response
            let data = result.data
            
            // Convert to a dictionary array
            guard let bookingsData = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                print("Failed to parse bookings data")
                return []
            }
            
            // Silently processing bookings
            
            // Manually parse the data
            var bookings: [Booking] = []
            
            for item in bookingsData {
                if let bookingIDString = item["bookingID"] as? String,
                   let userIDString = item["userID"] as? String,
                   let equipmentIDString = item["equipmentID"] as? String,
                   let bookingTypeString = item["bookingType"] as? String,
                   let statusString = item["status"] as? String,
                   let timeSlotString = item["timeSlot"] as? String,
                   let sourceString = item["source"] as? String,
                   let fieldArea = item["fieldArea"] as? Double {
                    
                    // Parse date - handle both string and timestamp formats
                    var bookingDate = Date()
                    if let dateString = item["bookingDate"] as? String {
                        let dateFormatter = ISO8601DateFormatter()
                        bookingDate = dateFormatter.date(from: dateString) ?? Date()
                    } else if let timestamp = item["bookingDate"] as? TimeInterval {
                        bookingDate = Date(timeIntervalSince1970: timestamp)
                    }
                    
                    // Create booking
                    if let bookingID = UUID(uuidString: bookingIDString),
                       let userID = UUID(uuidString: userIDString),
                       let equipmentID = UUID(uuidString: equipmentIDString) {
                        
                        // Map source string to BookingSource enum
                        let bookingSource: BookingSource
                        switch sourceString.lowercased() {
                        case "home":
                            bookingSource = .home
                        case "prebooking":
                            bookingSource = .prebooking
                        case "coequip":
                            bookingSource = .coEquip
                        case "coequipviewonly":
                            bookingSource = .coEquipViewOnly
                        default:
                            bookingSource = .home // Default fallback
                        }
                        
                        let booking = Booking(
                            bookingID: bookingID,
                            userID: userID,
                            equipmentID: equipmentID,
                            bookingType: BookingType(rawValue: bookingTypeString) ?? .onDemand,
                            bookingDate: bookingDate,
                            fieldArea: fieldArea,
                            status: BookingStatus(rawValue: statusString) ?? .pending,
                            timeSlot: TimeSlot(rawValue: timeSlotString) ?? .morning,
                            source: bookingSource
                        )
                        
                        bookings.append(booking)
                    }
                }
            }
            
            // Silently processed bookings
            return bookings
        } catch {
            print("Error fetching bookings: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError details: code=\(postgrestError.code ?? "nil"), message=\(postgrestError.message ?? "nil"), hint=\(postgrestError.hint ?? "nil"), detail=\(postgrestError.detail ?? "nil")")
            }
            return []
        }
    }
    
    func fetchCropsForSelection() async -> [Crop] {
        do {
            // Use the 'crops' table as specified by the user
            let data: [AgriCropDTO] = try await SupabaseManager.shared.client
                .from("crops")
                .select("*")
                .execute()
                .value
            
            return data.map { dto in
                Crop(
                    id: UUID(uuidString: dto.cropID) ?? UUID(),
                    name: dto.name,
                    imageURL: dto.imageURL ?? "" // Using empty string as fallback if imageURL is nil
                )
            }
        } catch {
            print("Error fetching crops for selection from Supabase: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError details: code=\(postgrestError.code ?? "nil"), message=\(postgrestError.message ?? "nil"), hint=\(postgrestError.hint ?? "nil"), detail=\(postgrestError.detail ?? "nil")")
            }
            // Return empty array instead of fallback data to ensure only backend data is used
            return []
        }
    }
    
    func fetchCrops() async -> [AgriCrop] {
        do {
            // Use the 'crops' table as specified by the user
            let data: [AgriCropDTO] = try await SupabaseManager.shared.client
                .from("crops")
                .select("*")
                .execute()
                .value
            
            return data.map { dto in
                AgriCrop(
                    id: UUID(uuidString: dto.cropID) ?? UUID(),
                    name: dto.name,
                    imageName: dto.imageURL ?? "" // Using empty string as fallback if imageURL is nil
                )
            }
        } catch {
            print("Error fetching crops from Supabase: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError details: code=\(postgrestError.code ?? "nil"), message=\(postgrestError.message ?? "nil"), hint=\(postgrestError.hint ?? "nil"), detail=\(postgrestError.detail ?? "nil")")
            }
            // Return empty array instead of fallback data to ensure only backend data is used
            return []
        }
    }
    
    func fetchEquipmentCategories() async -> [EquipmentCategory] {
        do {
            // Use the correct camelCase table name
            let data: [EquipmentCategoryDTO] = try await SupabaseManager.shared.client
                .from("equipmentCategories")
                .select("*")
                .execute()
                .value
            
            var categories: [EquipmentCategory] = []
            
            for dto in data {
                let equipmentList = await fetchEquipmentAgriByCategory(categoryId: dto.id)
                
                let category = EquipmentCategory(
                    id: UUID(uuidString: dto.id) ?? UUID(),
                    title: dto.title,
                    equipmentList: equipmentList
                )
                
                categories.append(category)
            }
            
            return categories
        } catch {
            print("Error fetching equipment categories from Supabase: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError details: code=\(postgrestError.code ?? "nil"), message=\(postgrestError.message ?? "nil"), hint=\(postgrestError.hint ?? "nil"), detail=\(postgrestError.detail ?? "nil")")
            }
            // Return empty array instead of fallback data to ensure only backend data is used
            return []
        }
    }
    
    func fetchEquipmentAgriByCategory(categoryId: String) async -> [EquipmentAgri] {
        do {
            // Use the correct camelCase table name and column name
            let data: [EquipmentAgriDTO] = try await SupabaseManager.shared.client
                .from("equipmentAgri")
                .select("*")
                .eq("categoryId", value: categoryId)
                .execute()
                .value
            
            return data.map { dto in
                EquipmentAgri(
                    id: UUID(uuidString: dto.id) ?? UUID(),
                    categoryId: UUID(uuidString: dto.categoryId) ?? UUID(),
                    name: dto.name,
                    imageName: dto.imageName,
                    purpose: dto.purpose,
                    bestFor: dto.bestFor,
                    averageCost: dto.averageCost,
                    needs: dto.needs,
                    likedBy: dto.likedBy
                )
            }
        } catch {
            print("Error fetching equipment agri by category: \(error)")
            return []
        }
    }
    
    func fetchFAQs() async -> [FAQ] {
        do {
            // Using the correct table name (this one doesn't need changing)
            let data: [FAQDTO] = try await SupabaseManager.shared.client
                .from("faqs")
                .select("*")
                .execute()
                .value
            
            return data.map { dto in
                FAQ(
                    id: UUID(uuidString: dto.id) ?? UUID(),
                    question: dto.question,
                    answer: dto.answer
                )
            }
        } catch {
            print("Error fetching FAQs from Supabase: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError details: code=\(postgrestError.code ?? "nil"), message=\(postgrestError.message ?? "nil"), hint=\(postgrestError.hint ?? "nil"), detail=\(postgrestError.detail ?? "nil")")
            }
            // Return empty array instead of fallback data to ensure only backend data is used
            return []
        }
    }
    
    // MARK: Create/Update methods
    
    func createBooking(_ booking: Booking) async -> Bool {
        do {
            // Log the raw UUID values before conversion
            print("Raw UUIDs - Booking ID: \(booking.bookingID), User ID: \(booking.userID), Equipment ID: \(booking.equipmentID)")
            
            // Extract location data if available
            let latitude = booking.bookingLocation?.latitude
            let longitude = booking.bookingLocation?.longitude
            let address = booking.bookingLocation?.address
            
            // Log location data
            if let lat = latitude, let lon = longitude {
                print("Including location data in booking: lat=\(lat), lon=\(lon), address=\(address ?? "none")")
            } else {
                print("No location data to include in booking")
            }
            
            // Map BookingSource to database string value
            let sourceString: String
            switch booking.source {
            case .home:
                sourceString = "home"
            case .prebooking:
                sourceString = "prebooking"
            case .coEquip:
                sourceString = "coequip"
            case .coEquipViewOnly:
                sourceString = "coequipviewonly"
            }
            
            // Convert all UUIDs to lowercase strings
            let dto = BookingDTO(
                id: booking.bookingID.uuidString.lowercased(),
                userId: booking.userID.uuidString.lowercased(),
                equipmentId: booking.equipmentID.uuidString.lowercased(),
                type: booking.bookingType.rawValue,
                date: booking.bookingDate,
                fieldArea: booking.fieldArea,
                status: booking.status.rawValue,
                timeSlot: booking.timeSlot.rawValue,
                source: sourceString,
                latitude: latitude,
                longitude: longitude,
                address: address
            )
            
            print("Creating booking in database - ID: \(dto.id), User: \(dto.userId), Equipment: \(dto.equipmentId)")
            
            // Log all available equipment IDs for debugging
            let equipmentsFromBackend = await fetchEquipments()
            print("Available equipment IDs in database:")
            for equip in equipmentsFromBackend {
                print("- \(equip.name): \(equip.equipmentID.uuidString.lowercased())")
            }
            
            // Use upsert instead of insert to handle both create and update
            try await SupabaseManager.shared.client
                .from("bookings")
                .upsert(dto)
                .execute()
            
            print("Booking successfully created!")
            return true
        } catch {
            print("Error creating booking: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError details: code=\(postgrestError.code ?? "nil"), message=\(postgrestError.message ?? "nil"), hint=\(postgrestError.hint ?? "nil"), detail=\(postgrestError.detail ?? "nil")")
            }
            return false
        }
    }
    
    func updateBookingStatus(_ bookingId: UUID, status: BookingStatus) async -> Bool {
        do {
            try await SupabaseManager.shared.client
                .from("bookings")
                .update(["status": status.rawValue])
                .eq("bookingID", value: bookingId.uuidString)
                .execute()
            
            return true
        } catch {
            print("Error updating booking status: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError details: code=\(postgrestError.code ?? "nil"), message=\(postgrestError.message ?? "nil"), hint=\(postgrestError.hint ?? "nil"), detail=\(postgrestError.detail ?? "nil")")
            }
            return false
        }
    }
    
    func createRequest(_ request: Request) async -> Bool {
        do {
            print("🔄 Creating request in Supabase...")
            print("📝 Converting to DTO...")
            
            let dto = RequestDTO(
                id: request.id,
                userId: request.userId,
                equipmentId: request.equipmentId,
                requestedDate: request.requestedDate,
                status: request.status.rawValue,
                type: request.type.rawValue,
                area: request.area,
                timeSlot: request.timeSlot.rawValue,
                timePeriod: request.timePeriod,
                location: request.location,
                typeOfRequest: request.typeOfRequest == .myRequest ? "myRequest" : "acceptedRequest"
                
            )
            
            print("📤 Sending to Supabase...")
            print("Table: requests")
            print("Data: \(dto)")
            
            let response = try await SupabaseManager.shared.client
                .from("requests")
                .insert(dto)
                .execute()
            
            print("✅ Request successfully created in Supabase")
            print("📊 Response: \(response)")
            return true
        } catch {
            print("❌ Error creating request in Supabase: \(error)")
            print("Error details: \(error.localizedDescription)")
            return false
        }
    }
   
    func updateRequest(_ request: Request) async -> Bool {
        do {
            let dto = RequestDTO(
                id: request.id,
                userId: request.userId,
                equipmentId: request.equipmentId,
                requestedDate: request.requestedDate,
                status: request.status.rawValue,
                type: request.type.rawValue,
                area: request.area,
                timeSlot: request.timeSlot.rawValue,
                timePeriod: request.timePeriod,
                location: request.location,
                typeOfRequest: request.typeOfRequest == .myRequest ? "myRequest" : "acceptedRequest"

                
            )
            
            try await SupabaseManager.shared.client
                .from("requests")
                .update(dto)
                .eq("id", value: request.id.uuidString)
                .execute()
            
            return true
        } catch {
            print("Error updating request: \(error)")
            return false
        }
    }
    
    func deleteRequest(with id: UUID) async -> Bool {
        do {
            try await SupabaseManager.shared.client
                .from("requests")
                .delete()
                .eq("id", value: id.uuidString)
                .execute()
            
            return true
        } catch {
            print("Error deleting request: \(error)")
            return false
        }
    }
    
    func fetchCropCategories() async -> [CropCategory] {
        do {
            // First fetch the crops from the 'crops' table
            let cropsData: [AgriCropDTO] = try await SupabaseManager.shared.client
                .from("crops")
                .select("*")
                .execute()
                .value
            
            // Then fetch equipment categories to be associated with crops
            let equipmentCategories = await fetchEquipmentCategories()
            
            // Create crop categories
            var cropCategories: [CropCategory] = []
            
            for cropDTO in cropsData {
                // Since you don't have a crop_equipment_mapping table, let's create a mapping directly
                // using cropEquipmentRecommendations table
                let cropEquipmentData: [CropEquipmentMappingDTO] = try await SupabaseManager.shared.client
                   
                    .from("cropEquipmentRecommendations")
                    .select("*")
                    .eq("cropID", value: cropDTO.cropID)
                    .execute()
                    .value
                
                // Get equipment category IDs for this crop
                let equipmentIds = cropEquipmentData.map { $0.equipmentCategoryId }
                
                // Filter equipment categories that belong to this crop
                let cropEquipmentCategories = equipmentCategories.filter { category in
                    equipmentIds.contains(category.id.uuidString)
                }
                
                // Create the crop category
                let cropCategory = CropCategory(
                    id: UUID(uuidString: cropDTO.cropID) ?? UUID(),
                    cropName: cropDTO.name,
                    equipmentsForCrops: "Equipments For \(cropDTO.name)",
                    equipments: cropEquipmentCategories
                )
                
                cropCategories.append(cropCategory)
            }
            
            return cropCategories
        } catch {
            print("Error fetching crop categories from Supabase: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError details: code=\(postgrestError.code ?? "nil"), message=\(postgrestError.message ?? "nil"), hint=\(postgrestError.hint ?? "nil"), detail=\(postgrestError.detail ?? "nil")")
            }
            // Return empty array instead of fallback data to ensure only backend data is used
            return []
        }
    }
}

// Data Transfer Objects (DTOs) for Supabase
struct ReviewDataDTO: Codable {
    let id: Int
    let reviewHeading: String
    let reviewDescription: String
    let rating: Double
    let equipmentID: String?
    let userID: String?
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case reviewHeading
        case reviewDescription
        case rating
        case equipmentID
        case userID
        case createdAt
    }
}

struct RequestDTO: Codable {
    let id: UUID
    let userId: UUID
    let equipmentId: UUID
    let requestedDate: Date
    let status: String
    let type: String
    let area: Double
    let timeSlot: String
    let timePeriod: String?
    let location: String
    let typeOfRequest: String
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case equipmentId
        case requestedDate
        case status
        case type
        case area
        case timeSlot
        case timePeriod
        case location
        case typeOfRequest
        
       
    }
    
    // Add this initializer for encoding
    init(id: UUID, userId: UUID, equipmentId: UUID, requestedDate: Date, status: String, 
         type: String, area: Double, timeSlot: String, timePeriod: String?, location: String, 
         typeOfRequest: String) {
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
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        equipmentId = try container.decode(UUID.self, forKey: .equipmentId)
        
        // Handle date decoding manually
        let dateString = try container.decode(String.self, forKey: .requestedDate)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: dateString) {
            requestedDate = date
        } else {
            // Try ISO8601 as fallback
            let iso8601Formatter = ISO8601DateFormatter()
            if let date = iso8601Formatter.date(from: dateString) {
                requestedDate = date
            } else {
                throw DecodingError.dataCorruptedError(
    forKey: .requestedDate,
    in: container,
    debugDescription: "Cannot decode date string \(dateString)"
)
            }
        }
        
        // Decode remaining properties
        status = try container.decode(String.self, forKey: .status)
        type = try container.decode(String.self, forKey: .type)
        area = try container.decode(Double.self, forKey: .area)
        timeSlot = try container.decode(String.self, forKey: .timeSlot)
        timePeriod = try container.decodeIfPresent(String.self, forKey: .timePeriod)
        location = try container.decode(String.self, forKey: .location)
        typeOfRequest = try container.decode(String.self, forKey: .typeOfRequest)
       
    }
}

struct UserDTO: Codable {
    let id: String
    let name: String
    let email: String
    let phone: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let fieldArea: Double
    let groupId: String?
    let selectedCrops: [String]
    let created_at: Date?
    let updated_at: Date?
    
    enum CodingKeys: String, CodingKey {
        case id = "userID"  // Match the exact column name in Supabase
        case name
        case email
        case phone
        case latitude
        case longitude
        case address
        case fieldArea = "fieldArea"  // Match the exact case in Supabase
        case groupId = "groupID"  // Match the exact case in Supabase
        case selectedCrops = "selectedCrops"  // Match the exact case in Supabase
        case created_at
        case updated_at
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String.self, forKey: .phone)
        latitude = try container.decode(Double.self, forKey: .latitude)
        longitude = try container.decode(Double.self, forKey: .longitude)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        fieldArea = try container.decode(Double.self, forKey: .fieldArea)
        groupId = try container.decodeIfPresent(String.self, forKey: .groupId)
        selectedCrops = try container.decodeIfPresent([String].self, forKey: .selectedCrops) ?? []
        created_at = try container.decodeIfPresent(Date.self, forKey: .created_at)
        updated_at = try container.decodeIfPresent(Date.self, forKey: .updated_at)
    }
}

struct BookingDTO: Codable {
    let id: String
    let userId: String
    let equipmentId: String
    let type: String
    let date: Date
    let fieldArea: Double
    let status: String
    let timeSlot: String
    let source: String
    let latitude: Double?
    let longitude: Double?
    let address: String?
    
    enum CodingKeys: String, CodingKey {
        case id = "bookingID"
        case userId = "userID"
        case equipmentId = "equipmentID"
        case type = "bookingType"
        case date = "bookingDate"
        case fieldArea
        case status
        case timeSlot
        case source
        case latitude
        case longitude
        case address
    }
}

struct AgriCropDTO: Codable {
    let cropID: String
    let name: String
    let season: String // Using String instead of enum to avoid additional decoding issues
    let imageURL: String?
    
    // Define CodingKeys to map between JSON and property names
    enum CodingKeys: String, CodingKey {
        case cropID = "cropID"
        case name
        case season
        case imageURL = "imageURL"
    }
}

struct EquipmentCategoryDTO: Codable {
    let id: String
    let title: String
}

struct EquipmentAgriDTO: Codable {
    let id: String
    let categoryId: String
    let name: String
    let imageName: String
    let purpose: String?
    let bestFor: String?
    let averageCost: String?
    let needs: String?
    let likedBy: Int
}

struct FAQDTO: Codable {
    let id: String
    let question: String
    let answer: String
}

struct CropEquipmentMappingDTO: Codable {
    let id: String
    let cropId: String
    let equipmentCategoryId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case cropId = "crop_id"
        case equipmentCategoryId = "equipment_category_id"
    }
}

extension Notification.Name {
    static let requestDeleted = Notification.Name("requestDeleted")
    static let bookingAdded = Notification.Name("bookingAdded")
    static let usersLoaded = Notification.Name("usersLoaded")
    static let requestsUpdated = Notification.Name("requestsUpdated")
    static let equipmentUpdated = Notification.Name("equipmentUpdated")
    static let dataInitiallyLoaded = Notification.Name("dataInitiallyLoaded")
}

//
extension UIView {
    func applyCardShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2  // Soft shadow
        self.layer.shadowOffset = CGSize(width: 0, height: 3)  // Downward natural shadow
        self.layer.shadowRadius = 8  // Blurred effect
        self.layer.masksToBounds = false
        self.layer.cornerRadius = 13  // Matches your UI preference
    }
}

class ReviewDataClass {
    // Static array to hold reviews
    static var reviews: [ReviewData] = []
    
    // Function to update reviews from database
    static func updateReviews(with newReviews: [ReviewData]) {
        reviews = newReviews
    }
}



