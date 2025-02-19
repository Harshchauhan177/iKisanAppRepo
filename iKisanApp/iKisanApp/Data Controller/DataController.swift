//
//  DataController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 30/01/25.
//

import Foundation


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
    
    // AgriAssist Related Functions
    func getAllCrops() -> [AgriCrop]
    func getCropCategory(forCrop cropId: UUID) -> CropCategory?
    func getEquipmentCategories(forCrop cropId: UUID) -> [EquipmentCategory]
    func getEquipmentAgri(forCategory categoryId: UUID) -> [EquipmentAgri]
    func getEquipmentAgriDetails(id: UUID) -> EquipmentAgri?
    
    // Add  new functions for InfoAboutEquipments
    func getEquipmentSectionHeaders() -> [String]
    func getEquipmentTypeDetails() -> [EquipmentAgri]
    func getRelatedEquipment() -> [EquipmentAgri]
    
    // Add  new function for SameTypeAllEquipments
    func getEquipmentsByCategory(categoryId: UUID) -> [EquipmentAgri]
    
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
    
    
}


enum SortOption {
    case priceHighToLow
    case priceLowToHigh
    case rating
    case name
}

enum EquipmentData {
    static let equipment: [Equipment] = [
        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Square Baler", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "4.jpeg", name: "Rice Harvester", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1100,realPricePerHour: 1500 , pricePerAcre: 2200, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Gunpura, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "2.jpeg", name: "Trailed Sprayers", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1200,realPricePerHour: 1500 , pricePerAcre: 2300, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Dankaur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["2.jpeg","2.jpeg","2.jpeg","2.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "5.jpeg", name: "Harrow", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1300,realPricePerHour: 1500 , pricePerAcre: 2400, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Bisrakh, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["5.jpeg","5.jpeg","5.jpeg","5.jpeg","5.jprg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "6.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1400,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Alpha2, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "7.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
      
    ]
    
    static let reviews: [ReviewData] = [
        ReviewData(reviewHeading: "Excellent", reviewDescription: "Rented the Swaraj Combine for my rice field, and it worked like a charm! Great fuel efficiency, easy handling, and the rental process was smooth.", rating: 4),
        ReviewData(reviewHeading: "Good", reviewDescription: "Rented the Swaraj Combine for my rice field, and it worked like a charm! Great fuel efficiency, easy handling, and the rental process was smooth.", rating: 3),
        ReviewData(reviewHeading: "Bad", reviewDescription: "The Swaraj Combine was disappointing. It kept breaking down, fuel consumption was high, and I lost valuable time waiting for repairs. Not worth the hassle.", rating: 2),
        ReviewData(reviewHeading: "Very Bad", reviewDescription: "The Swaraj Combine was disappointing. It kept breaking down, fuel consumption was high, and I lost valuable time waiting for repairs. Not worth the hassle.", rating: 1),
        
        ]
    static let suggestionsEquipment: [Equipment] = [
        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Square Baler", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
        Equipment(equipmentID: UUID(), equipmentImage: "4.jpeg", name: "Rice Harvester", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1100,realPricePerHour: 1500 , pricePerAcre: 2200, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Gunpura, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
        Equipment(equipmentID: UUID(), equipmentImage: "2.jpeg", name: "Trailed Sprayers", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1200,realPricePerHour: 1500 , pricePerAcre: 2300, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Dankaur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["2.jpeg","2.jpeg","2.jpeg","2.jpeg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
        Equipment(equipmentID: UUID(), equipmentImage: "5.jpeg", name: "Harrow", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1300,realPricePerHour: 1500 , pricePerAcre: 2400, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Bisrakh, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["5.jpeg","5.jpeg","5.jpeg","5.jpeg","5.jprg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
    ]
}

class IKisanDataController: DataController {
    
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

    
    
    
    private var equipmentList: [Equipment]
    private var reviewList: [ReviewData]
    private var suggestionList: [Equipment]
    private var bookingsList: [Booking] = []
    // agri Assist
    private let crops: [AgriCrop]
    private var cropCategories: [CropCategory]
    private let sectionHeaders = ["Equipment Type Details", "Related Equipment"]
    private var coEquipRequests: [Request] = []
    private var acceptedRequests: [Request] = []
    private var pendingRequests: [Request] = []
    private let sampleUsers: [User] = [
        User(userID: UUID(), name: "Rahul Kumar", phone: "9876543210", 
             location: Location(latitude: 28.4744, longitude: 77.5040, address: "Greater Noida"), 
             selectedCrops: [], fieldArea: 5.0),
        User(userID: UUID(), name: "Amit Singh", phone: "8765432109", 
             location: Location(latitude: 28.4745, longitude: 77.5041, address: "Noida"), 
             selectedCrops: [], fieldArea: 3.5),
        User(userID: UUID(), name: "Priya Sharma", phone: "7654321098", 
             location: Location(latitude: 28.4746, longitude: 77.5042, address: "Delhi"), 
             selectedCrops: [], fieldArea: 4.0)
    ]
    init() {
        self.equipmentList = EquipmentData.equipment
        self.reviewList = EquipmentData.reviews
        self.suggestionList = EquipmentData.suggestionsEquipment
        
        
        // Initialize crops
        self.crops = [
            AgriCrop(id: Self.riceId, name: "Rice", imageName: "Rice"),
            AgriCrop(id: Self.wheatId, name: "Wheat", imageName: "Wheat"),
            AgriCrop(id: Self.oatsId, name: "Oats", imageName: "Oats"),
            AgriCrop(id: Self.cottonId, name: "Cotton", imageName: "Cotton"),
            AgriCrop(id: Self.teaId, name: "Tea", imageName: "Tea"),
            AgriCrop(id: Self.maizeId, name: "Maize", imageName: "Maize"),
            AgriCrop(id: Self.tobaccoId, name: "Tobacco", imageName: "Tobacco"),
            AgriCrop(id: Self.sugarcaneId, name: "Sugarcane", imageName: "Sugarcane")
        ]
        
        // Initialize crop categories with updated EquipmentAgri instances
        self.cropCategories = [
            CropCategory(
                id: Self.riceId,
                cropName: "Rice",equipmentsForCrops: "Equipments For Rice",
                equipments: [
                    EquipmentCategory(
                        id: Self.cultivatorsCategoryId,
                        title: "Cultivators",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.paddleWheelCultivatorId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Spring",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Rigid",imageName: "Image 2",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Rotary",imageName: "Image 3",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Power",imageName: "Image 4",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Mini",imageName: "Image 5",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.harvestersCategoryId,
                        title: "Harrow",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.riceHarvesterId,
                                categoryId: Self.harvestersCategoryId,  // Add categoryId
                                name: "Disc",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Spike",imageName: "Image 3",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Chain",imageName: "Image 4",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Tine",imageName: "Image 5",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.harvestersCategoryId,
                        title: "Seeder",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.riceHarvesterId,
                                categoryId: Self.harvestersCategoryId,  // Add categoryId
                                name: "Paddy",imageName: "Image 2",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Direct",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Drum",imageName: "Image 3",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.powerTillerId,
                                categoryId: Self.cultivatorsCategoryId,  // Add categoryId
                                name: "Automatic",imageName: "Image 5",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    )
                ]
            ),
            CropCategory(
                id: Self.wheatId,
                cropName: "Wheat",
                equipmentsForCrops: "Equipments For Wheat",
                equipments: [
                    EquipmentCategory(
                        id: Self.seedersCategoryId,
                        title: "Plough",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.wheatSeederId,
                                categoryId: Self.seedersCategoryId,
                                name: "Mouldboard",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: UUID(),
                                categoryId: Self.seedersCategoryId,
                                name: "Reversible",imageName: "Image 5",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: UUID(),
                                categoryId: Self.seedersCategoryId,
                                name: "Chisel",imageName: "Image 6",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: UUID(),
                                categoryId: Self.seedersCategoryId,
                                name: "Disc",imageName: "Image 3",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.harvestersCategoryId,
                        title: "Seeder",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.wheatHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Broadcast",imageName: "Image 4",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.wheatHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Air",imageName: "Image 3",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.wheatHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Seed",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.wheatHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Precision",imageName: "Image 6",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    )
                ]
            ),
            
            CropCategory(
                id: Self.oatsId,
                cropName: "Oats",
                equipmentsForCrops: "Equipments For Oats",
                equipments: [
                    EquipmentCategory(
                        id: Self.planterCategoryId,
                        title: "Planter",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Sugarcane",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Row Sugarcane",imageName: "Image 2",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Automatic",imageName: "Image 4",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Manual",imageName: "Image 5",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    ),EquipmentCategory(
                        id: Self.planterCategoryId,
                        title: "Planter",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Sugarcane",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45  ),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Row Sugarcane",imageName: "Image 2",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Automatic",imageName: "Image 4",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Manual",imageName: "Image 5",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.planterCategoryId,
                        title: "Planter",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Sugarcane",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Row Sugarcane",imageName: "Image 2",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Automatic",imageName: "Image 4",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45  ),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Manual",imageName: "Image 5",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.planterCategoryId,
                        title: "Planter",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Sugarcane",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Row Sugarcane",imageName: "Image 2",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Automatic",imageName: "Image 4",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cottonSeederId,
                                categoryId: Self.planterCategoryId,
                                name: "Manual",imageName: "Image 5",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    )
                ]
            ),
            CropCategory(
                id: Self.cottonId,
                cropName: "Cotton",
                equipmentsForCrops: "Equipments For Cotton",
                equipments: [
                    EquipmentCategory(
                        id: Self.cultivatorsCategoryId,
                        title: "Cultivator",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.sugarcanePlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Shovel",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45  ),
                            EquipmentAgri(
                                id: Self.sugarcanePlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Tine",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.sugarcanePlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Rotary",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.sugarcanePlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Mini",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.planterCategoryId,
                        title: "Planter",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.sugarcanePlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Cotton",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45 ),
                            EquipmentAgri(
                                id: Self.sugarcanePlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Air Seed",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.sugarcanePlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Drill",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45 ),
                            EquipmentAgri(
                                id: Self.sugarcanePlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Precision",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.harvestersCategoryId,
                        title: "Harvesters",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.sugarcaneHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Cotton",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45 ),
                            EquipmentAgri(
                                id: Self.chopperHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Stripper",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45 ),
                            EquipmentAgri(
                                id: Self.chopperHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Combine",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.chopperHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Self-Propelled",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45 )
                        ]
                    )
                ]
            ),
            CropCategory(
                id: Self.teaId,
                cropName: "Tea",
                equipmentsForCrops: "Equipments For Tea",
                equipments: [
                    EquipmentCategory(
                        id: Self.planterCategoryId,
                        title: "Pruner",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.cornPlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Tea",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cornPlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Handheld",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cornPlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Hydraulic",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.cornPlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Battery Operated",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45)
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.harvestersCategoryId,
                        title: "Harvesters",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.maizeHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Tea Plucking",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                            EquipmentAgri(
                                id: Self.maizeHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Shear",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45),
                        ]
                    )
                ]
            ),
            CropCategory(
                id: Self.maizeId,
                cropName: "Maize",
                equipmentsForCrops: "Maize Equipment",
                equipments: [
                    EquipmentCategory(
                        id: Self.planterCategoryId,
                        title: "Planters",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.cornPlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Paddle Wheel Cultivator",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45
                            )
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.harvestersCategoryId,
                        title: "Harvesters",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.maizeHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Paddle Wheel Cultivator",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45
                            )
                        ]
                    )
                ]
            ),CropCategory(
                id: Self.tobaccoId,
                cropName: "Maize",
                equipmentsForCrops: "Maize Equipment",
                equipments: [
                    EquipmentCategory(
                        id: Self.planterCategoryId,
                        title: "Planters",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.cornPlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Paddle Wheel Cultivator",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45
                            )
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.harvestersCategoryId,
                        title: "Harvesters",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.maizeHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Paddle Wheel Cultivator",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45
                            )
                        ]
                    )
                ]
            ),CropCategory(
                id: Self.sugarcaneId,
                cropName: "Maize",
                equipmentsForCrops: "Maize Equipment",
                equipments: [
                    EquipmentCategory(
                        id: Self.planterCategoryId,
                        title: "Planters",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.cornPlanterId,
                                categoryId: Self.planterCategoryId,
                                name: "Paddle Wheel Cultivator",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45
                            )
                        ]
                    ),
                    EquipmentCategory(
                        id: Self.harvestersCategoryId,
                        title: "Harvesters",
                        equipmentList: [
                            EquipmentAgri(
                                id: Self.maizeHarvesterId,
                                categoryId: Self.harvestersCategoryId,
                                name: "Paddle Wheel Cultivator",imageName: "Image 1",purpose: "For paddy fields",bestFor: "Small farms",averageCost: "₹1000/day",needs: "Tractor attachment",likedBy: 45
                            )
                        ]
                    )
                ]
            )
        ]

        setupInitialRequests()
    }
    
    private func setupInitialRequests() {
        // Create some accepted requests using the existing equipment data
        acceptedRequests = [] // Remove dummy data, start with empty array
        
        // Add these requests to coEquipRequests as well
        coEquipRequests.append(contentsOf: acceptedRequests)
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
    }
    
    func getSuggestions() -> [Equipment] {
        return suggestionList
    }
    
    func getEquipment(sortedBy option: SortOption) -> [Equipment] {
        switch option {
        case .priceHighToLow:
            return equipmentList.sorted { $0.pricePerHour > $1.pricePerHour }
        case .priceLowToHigh:
            return equipmentList.sorted { $0.pricePerHour < $1.pricePerHour }
        case .rating:
            return equipmentList.sorted { $0.rating > $1.rating }
        case .name:
            return equipmentList.sorted { $0.name < $1.name }
        }
    }
    

    func searchEquipment(query: String) -> [Equipment] {
        let lowercasedQuery = query.lowercased()
        return equipmentList.filter {
            $0.name.lowercased().contains(lowercasedQuery) ||
            $0.type.lowercased().contains(lowercasedQuery) ||
            $0.location.lowercased().contains(lowercasedQuery)
        }
    }
    
    // AgriAssist implementations
    func getAllCrops() -> [AgriCrop] {
        return crops
    }
    
    func getCropCategory(forCrop cropId: UUID) -> CropCategory? {
        print("Looking for crop category with ID: \(cropId)")
        let category = cropCategories.first { $0.id == cropId }
        print("Found category: \(category?.cropName ?? "nil")")
        return category
    }
    
    func getEquipmentCategories(forCrop cropId: UUID) -> [EquipmentCategory] {
        print("Looking for equipment categories for crop ID: \(cropId)")
        let categories = cropCategories.first { $0.id == cropId }?.equipments ?? []
        print("Found \(categories.count) equipment categories")
        return categories
    }
    
    func getEquipmentAgri(forCategory categoryId: UUID) -> [EquipmentAgri] {
        return cropCategories.flatMap { $0.equipments }
            .first { $0.id == categoryId }?.equipmentList ?? []
    }
    
    func getEquipmentAgriDetails(id: UUID) -> EquipmentAgri? {
        return cropCategories.flatMap { $0.equipments }
            .flatMap { $0.equipmentList }
            .first { $0.id == id }
    }
    
    // Static section headers
    func getEquipmentSectionHeaders() -> [String] {
        return sectionHeaders
    }
    
    func getEquipmentTypeDetails() -> [EquipmentAgri] {
        // Return equipment details from first section
        return cropCategories.flatMap { $0.equipments }
            .flatMap { $0.equipmentList }
    }
    
    func getRelatedEquipment() -> [EquipmentAgri] {
        // Return related equipment from second section
        return cropCategories.flatMap { $0.equipments }
            .flatMap { $0.equipmentList }
            .filter { $0.purpose != nil } // Or any other filtering logic
    }
    
    func getEquipmentsByCategory(categoryId: UUID) -> [EquipmentAgri] {
        return cropCategories.flatMap { $0.equipments }
            .first { $0.id == categoryId }?.equipmentList ?? []
    }
    
    // home -------
    
    func getUpcomingBookings() -> [Booking] {
        let upcoming = bookingsList.filter { $0.status != .completed }
            .sorted { $0.bookingDate > $1.bookingDate }
        return upcoming
    }
    
    func addBooking(_ booking: Booking) {
        // Check if booking already exists
        if !bookingsList.contains(where: { $0.bookingID == booking.bookingID }) {
            bookingsList.append(booking)
        } else {
            print("DataController - Booking with ID \(booking.bookingID) already exists")
        }
    }
    func isEquipmentAvailable(on date: Date, for equipmentName: String) -> Bool {
        if let equipment = equipmentList.first(where: { $0.name == equipmentName }) {
            return equipment.isAvailable(on: date)
        }
        return false
    }
    // MARK: - CoEquip Methods
    
    func getAllCoEquipRequests() -> [Request] {
        return coEquipRequests
    }
    
    func getAcceptedRequests() -> [Request] {
        return acceptedRequests
    }
    
    func addNewCoEquipRequest(_ request: Request) {
        // Check if request already exists
        if !coEquipRequests.contains(where: { $0.id == request.id }) {
            coEquipRequests.append(request)
        }
    }
    
    func updateRequest(_ request: Request) {
        if let index = coEquipRequests.firstIndex(where: { $0.id == request.id }) {
            coEquipRequests[index] = request
        }
    }
    func deleteRequest(with id: UUID) {
        
        // Remove from coEquip requests
        if let index = coEquipRequests.firstIndex(where: { $0.id == id }) {
            coEquipRequests.remove(at: index)
        }
        
        // Remove from pending requests
        if let index = pendingRequests.firstIndex(where: { $0.id == id }) {
            pendingRequests.remove(at: index)
        }
        
        // Remove from accepted requests
        if let index = acceptedRequests.firstIndex(where: { $0.id == id }) {
            acceptedRequests.remove(at: index)
        }
        
        // Notify observers
        NotificationCenter.default.post(
            name: .requestDeleted,
            object: nil,
            userInfo: ["requestId": id]
        )
    }
    
    func getEquipmentById(_ id: UUID) -> Equipment? {
        return equipmentList.first { $0.equipmentID == id }
    }
    
    func getCoEquipUsers() -> [User] {
        // Return list of users who can participate in co-equip
        return []
    }
    func getEquipmentSuggestions() -> [String] {
        return [
            "Harvester", "Rice Harvester", "Wheat Harvester",
            "Sugarcane Harvester", "Tractor", "Mini Tractor",
            "Farm Tractor", "Plough", "Rotavator", "Cultivator",
            "Sprayer", "Seeder", "Thresher", "Potato Harvester",
            "Cotton Picker"
        ]
    }
    
    func filterEquipment(by query: String) -> [Equipment] {
        _ = query.lowercased()
        return [] // Placeholder implementation
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
            equipment.type.lowercased().contains(lowercasedQuery)
        }
    }
    
    func isEquipmentAvailable(on date: Date, for equipment: Equipment) -> Bool {
        return equipment.isAvailable(on: date)
    }
    
    func createRequest(_ request: Request) {
        coEquipRequests.append(request)
    }
    func getTimeSlots(for area: Double) -> [TimeSlot] {
        let duration = Int(area * 30) // 30 minutes per acre
        if duration <= 240 { // 4 hours
            return [.morning]
        } else if duration <= 480 { // 8 hours
            return [.morning, .afternoon]
        } else {
            return [.morning, .afternoon, .evening]
        }
    }
    
    // Method to get sample users
    func getSampleUsers() -> [User] {
        return sampleUsers
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

    private init() {
        equipmentItems = [
            Equipment(equipmentID: UUID(), equipmentImage: "5.jpeg", name: "Harrow", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1300,realPricePerHour: 1500 , pricePerAcre: 2400, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Bisrakh, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["5.jpeg","5.jpeg","5.jpeg","5.jpeg","5.jprg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
        ]
    }
}

extension Notification.Name {
    static let requestDeleted = Notification.Name("requestDeleted")
}



