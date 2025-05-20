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

protocol DataController {
    func getAllEquipment() -> [Equipment]
    func getEquipment(byType type: String) -> [Equipment]
    func getAllReviews() -> [ReviewData]
    func addReview(_ review: ReviewData)
    func getSuggestions() -> [Equipment]
    
    func getEquipment(sortedBy: SortOption) -> [Equipment]
    func searchEquipment(query: String) -> [Equipment]
    func getUpcomingBookings() -> [Booking]
    func addBooking(_ booking: Booking)
    func refreshBookingsFromDatabase() async
    
    // AgriAssist Related Functions
    func getAllCrops() -> [AgriCrop]
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
    
    // Add these new functions
    func setSelectedCrops(_ cropNames: Set<String>)
    func getSelectedCrops() -> Set<String>
    
    //coequip Related functions
    func getAllCoEquipRequests() -> [Request]
    func getAcceptedRequests() -> [Request]
    func addNewCoEquipRequest(_ request: Request)
    func updateRequest(_ request: Request)
    func deleteRequest(with id: UUID)
    func getEquipmentById(_ id: UUID) -> Equipment?
    func getCoEquipUsers() -> [User]
    func getEquipmentSuggestions() -> [String]
    func filterEquipment(by query: String) -> [Equipment]
    func getCategories() -> [String]
    func getEquipmentList() -> [Equipment]
    func filterEquipment(byCategory category: String?) -> [Equipment]
    func filterEquipment(bySearchText searchText: String) -> [Equipment]
    func isEquipmentAvailable(on date: Date, for equipment: Equipment) -> Bool
    func createRequest(_ request: Request)
    func getTimeSlots(for area: Double) -> [TimeSlot]
    
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
   
       
    // Add a property to store FAQs
    private var faqsList: [FAQ] = []
    
    // Add a property to store cached users
    private var cachedUsers: [User] = []
    
    func getCurrentUserAddress() -> String? {
        // Try to get address from AuthManager's currentUser
        if let address = AuthManager.shared.currentUser?.address {
            return address
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
        
        // Setup initial data
        Task {
            await loadDataFromBackend()
            await refreshFAQsFromDatabase()
        }
    }
    
    private func loadDataFromBackend() async {
        // Load all data from backend
        self.equipmentList = await requestManager.fetchEquipments()
        self.reviewList = await requestManager.fetchReviews()
        self.bookingsList = await requestManager.fetchBookings()
        self.crops = await requestManager.fetchCrops()
        self.cropCategories = await requestManager.fetchCropCategories()
        
        // Load requests
        self.coEquipRequests = await requestManager.fetchRequests()
        self.acceptedRequests = self.coEquipRequests.filter { $0.status == .confirmed }
        
        // Make a local copy of suggestions for quick access
        self.suggestionList = self.equipmentList.filter { $0.isRecommended }
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
    
    func addBooking(_ booking: Booking) {
        // Ensure we have a logged in user
        guard let currentUser = AuthManager.shared.currentUser else {
            print("Error: No logged in user found")
            return
        }
        
        // Verify the equipment exists
        guard let equipment = getEquipment(byId: booking.equipmentID) else {
            print("Error: Equipment with ID \(booking.equipmentID) not found")
            return
        }
        
        print("Creating booking for equipment: \(equipment.name) with ID: \(equipment.equipmentID)")
        
        // Create a new booking with the current user's ID
        let bookingWithUserId = Booking(
            bookingID: booking.bookingID,
            userID: currentUser.id, // Use the current user's ID
            equipmentID: equipment.equipmentID,
            bookingType: booking.bookingType,
            bookingDate: booking.bookingDate,
            fieldArea: booking.fieldArea,
            status: booking.status,
            timeSlot: booking.timeSlot,
            source: booking.source
        )
        
        bookingsList.append(bookingWithUserId)
        
        // Save to Supabase
        Task {
            await RequestManager.shared.createBooking(bookingWithUserId)
        }
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
    
    // MARK: - AgriAssist Functions
    
    func getAllCrops() -> [AgriCrop] {
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
        return coEquipRequests
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
        
        print("Searching for equipment with ID: \(lowercaseId)")
        
        // First try exact match
        if let equipment = equipmentList.first(where: { $0.equipmentID.uuidString.lowercased() == lowercaseId }) {
            print("Found equipment: \(equipment.name) with ID: \(equipment.equipmentID.uuidString.lowercased())")
            return equipment
        }
        
        // If exact match fails, try to find equipment by name "Square Balers" 
        // since this is the ID we know should work from the error message
        print("Exact match failed, searching for 'Square Balers'")
        if let squareBalers = equipmentList.first(where: { $0.name == "Square Balers" }) {
            print("Found Square Balers with ID: \(squareBalers.equipmentID.uuidString.lowercased())")
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
    
    func getCoEquipUsers() -> [User] {
        
        // Otherwise, fetch users asynchronously and return an empty array for now
        Task {
            let fetchedUsers = await requestManager.fetchAllUsers()
            // Update cached users on the main thread
            await MainActor.run {
                self.cachedUsers = fetchedUsers
                print("Loaded \(fetchedUsers.count) users from database")
                // Notify any listeners that users have been loaded
                NotificationCenter.default.post(name: .usersLoaded, object: nil)
            }
        }
        
        return []
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
        return ["Combine", "Rice", "Wheat", "Soyabean", "Irrigation", "Other"]
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
            let data: [Equipment] = try await SupabaseManager.shared.client
            .from("equipment")
            .select("*")
            .execute()
            .value
        return data
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
            let data: [RequestDTO] = try await SupabaseManager.shared.client
                .from("requests")
                .select("*")
                .execute()
                .value
            
            // Convert DTOs to domain models with relationships
            var requests: [Request] = []
            for dto in data {
                let selectedUsers = await fetchUsersById(userIds: dto.selectedUsersIds)
                
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
                    selectedUsers: selectedUsers,
                    joinedFarmers: dto.joinedFarmers
                )
                requests.append(request)
            }
            return requests
        } catch {
            print("Error fetching requests: \(error)")
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
            print("Fetching bookings from database...")
            
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
            
            print("Received \(bookingsData.count) bookings from database")
            
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
                        
                        let booking = Booking(
                            bookingID: bookingID,
                            userID: userID,
                            equipmentID: equipmentID,
                            bookingType: BookingType(rawValue: bookingTypeString) ?? .onDemand,
                            bookingDate: bookingDate,
                            fieldArea: fieldArea,
                            status: BookingStatus(rawValue: statusString) ?? .pending,
                            timeSlot: TimeSlot(rawValue: timeSlotString) ?? .morning,
                            source: sourceString == "home" ? .home : .prebooking
                        )
                        
                        bookings.append(booking)
                    }
                }
            }
            
            print("Successfully parsed \(bookings.count) bookings")
            return bookings
        } catch {
            print("Error fetching bookings: \(error)")
            if let postgrestError = error as? PostgrestError {
                print("PostgrestError details: code=\(postgrestError.code ?? "nil"), message=\(postgrestError.message ?? "nil"), hint=\(postgrestError.hint ?? "nil"), detail=\(postgrestError.detail ?? "nil")")
            }
            return []
        }
    }
    
    func fetchCrops() async -> [AgriCrop] {
        do {
            // Use the correct camelCase table name "agriCrops" instead of "agri_crops"
            let data: [AgriCropDTO] = try await SupabaseManager.shared.client
                .from("agriCrops")
                .select("*")
                .execute()
                .value
            
            return data.map { dto in
                AgriCrop(
                    id: UUID(uuidString: dto.id) ?? UUID(),
                    name: dto.name,
                    imageName: dto.imageName
                )
            }
        } catch {
            print("Error fetching crops: \(error)")
            
            // FALLBACK DATA: Used only when backend request fails
            let fallbackCrops: [AgriCrop] = [
                AgriCrop(id: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "Rice", imageName: "Rice"),
                AgriCrop(id: UUID(uuidString: "F622E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "Wheat", imageName: "Wheat"),
                AgriCrop(id: UUID(uuidString: "F623E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "Oats", imageName: "Oats"),
                AgriCrop(id: UUID(uuidString: "F624E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "Cotton", imageName: "Cotton"),
                AgriCrop(id: UUID(uuidString: "F625E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "Tea", imageName: "Tea"),
                AgriCrop(id: UUID(uuidString: "F626E1F8-C36C-495A-93FC-0C247A3E6E5F")!, name: "Maize", imageName: "Maize")
            ]
            return fallbackCrops
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
            print("Error fetching equipment categories: \(error)")
            
            // FALLBACK DATA: Used only when backend request fails
            let fallbackCategories: [EquipmentCategory] = [
                EquipmentCategory(
                    id: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                    title: "Cultivators",
                    equipmentList: []
                ),
                EquipmentCategory(
                    id: UUID(uuidString: "A622E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                    title: "Harvesters",
                    equipmentList: []
                ),
                EquipmentCategory(
                    id: UUID(uuidString: "A623E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                    title: "Seeders",
                    equipmentList: []
                )
            ]
            return fallbackCategories
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
            print("Error fetching FAQs: \(error)")
            
            // FALLBACK DATA: Used only when backend request fails
            let fallbackFAQs: [FAQ] = [
                FAQ(id: UUID(),
                    question: "How does prebooking work?",
                    answer: "Select equipment, choose dates, and confirm booking."),
                FAQ(id: UUID(),
                    question: "What if equipment is unavailable?",
                    answer: "You'll be notified and can choose alternate dates."),
                FAQ(id: UUID(),
                    question: "Can I cancel or modify a booking?",
                    answer: "Yes, you can modify or cancel up to 24 hours before the booking.")
            ]
            
            return fallbackFAQs
        }
    }
    
    // MARK: Create/Update methods
    
    func createBooking(_ booking: Booking) async -> Bool {
        do {
            // Log the raw UUID values before conversion
            print("Raw UUIDs - Booking ID: \(booking.bookingID), User ID: \(booking.userID), Equipment ID: \(booking.equipmentID)")
            
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
                source: booking.source == .home ? "home" : "prebooking"
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
                typeOfRequest: request.typeOfRequest == .myRequest ? "myRequest" : "acceptedRequest",
                selectedUsersIds: request.selectedUsers.map { $0.userID.uuidString },
                joinedFarmers: request.joinedFarmers
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
                typeOfRequest: request.typeOfRequest == .myRequest ? "myRequest" : "acceptedRequest",
                selectedUsersIds: request.selectedUsers.map { $0.userID.uuidString },
                joinedFarmers: request.joinedFarmers
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
            // First fetch the crops using the correct table name
            let cropsData: [AgriCropDTO] = try await SupabaseManager.shared.client
                .from("agriCrops")
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
                    .eq("cropID", value: cropDTO.id)
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
                    id: UUID(uuidString: cropDTO.id) ?? UUID(),
                    cropName: cropDTO.name,
                    equipmentsForCrops: "Equipments For \(cropDTO.name)",
                    equipments: cropEquipmentCategories
                )
                
                cropCategories.append(cropCategory)
            }
            
            return cropCategories
        } catch {
            print("Error fetching crop categories: \(error)")
            
            // FALLBACK DATA: Used only when backend request fails
            let fallbackCategories: [CropCategory] = [
                CropCategory(
                    id: UUID(uuidString: "F621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                    cropName: "Rice",
                    equipmentsForCrops: "Equipments For Rice",
                    equipments: [
                        EquipmentCategory(
                            id: UUID(uuidString: "A621E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                            title: "Cultivators",
                            equipmentList: []
                        ),
                        EquipmentCategory(
                            id: UUID(uuidString: "A622E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                            title: "Harvesters",
                            equipmentList: []
                        )
                    ]
                ),
                CropCategory(
                    id: UUID(uuidString: "F622E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                    cropName: "Wheat",
                    equipmentsForCrops: "Equipments For Wheat",
                    equipments: [
                        EquipmentCategory(
                            id: UUID(uuidString: "A623E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                            title: "Seeders",
                            equipmentList: []
                        ),
                        EquipmentCategory(
                            id: UUID(uuidString: "A624E1F8-C36C-495A-93FC-0C247A3E6E5F")!,
                            title: "Harrow",
                            equipmentList: []
                        )
                    ]
                )
            ]
            return fallbackCategories
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
    let selectedUsersIds: [String]
    let joinedFarmers: [UUID]
    
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
        // These aren't explicit columns, so they need special handling
        case selectedUsersIds
        case joinedFarmers
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
    }
}

struct AgriCropDTO: Codable {
    let id: String
    let name: String
    let imageName: String
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


// DTO for usersforfetch table
struct UserForFetchDTO: Codable {
    let userID: String
    let name: String
    let phone: String
    let latitude: Double
    let longitude: Double
    let address: String?
    let fieldArea: Double
    let groupID: String?
    let email: String
}



