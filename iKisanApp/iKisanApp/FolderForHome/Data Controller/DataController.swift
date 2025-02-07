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
}

enum SortOption {
    case priceHighToLow
    case priceLowToHigh
    case rating
    case name
}



//class EquipmentData: DataController {
//    static /*private*/ var equipment: [Equipment] = [
//        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Square Baler", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
//        Equipment(equipmentID: UUID(), equipmentImage: "4.jpeg", name: "Rice Harvester", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1100,realPricePerHour: 1500 , pricePerAcre: 2200, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Gunpura, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
//        Equipment(equipmentID: UUID(), equipmentImage: "2.jpeg", name: "Trailed Sprayers", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1200,realPricePerHour: 1500 , pricePerAcre: 2300, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Dankaur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["2.jpeg","2.jpeg","2.jpeg","2.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
//        Equipment(equipmentID: UUID(), equipmentImage: "5.jpeg", name: "Harrow", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1300,realPricePerHour: 1500 , pricePerAcre: 2400, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Bisrakh, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["5.jpeg","5.jpeg","5.jpeg","5.jpeg","5.jprg"]), modelYear: "2009", mielage: "15L/ac"),
//        Equipment(equipmentID: UUID(), equipmentImage: "6.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1400,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Alpha2, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
//        Equipment(equipmentID: UUID(), equipmentImage: "7.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
//        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
//      
//    ]
//    
//    static /*private*/ var reviews: [ReviewData] = [
//        ReviewData(reviewHeading: "Excellent", reviewDescription: "Rented the Swaraj Combine for my rice field, and it worked like a charm! Great fuel efficiency, easy handling, and the rental process was smooth.", rating: 4),
//        ReviewData(reviewHeading: "Good", reviewDescription: "Rented the Swaraj Combine for my rice field, and it worked like a charm! Great fuel efficiency, easy handling, and the rental process was smooth.", rating: 3),
//        ReviewData(reviewHeading: "Bad", reviewDescription: "The Swaraj Combine was disappointing. It kept breaking down, fuel consumption was high, and I lost valuable time waiting for repairs. Not worth the hassle.", rating: 2),
//        ReviewData(reviewHeading: "Very Bad", reviewDescription: "The Swaraj Combine was disappointing. It kept breaking down, fuel consumption was high, and I lost valuable time waiting for repairs. Not worth the hassle.", rating: 1),
//        
//        ]
//    static /*private*/ var suggestionsEquipment: [Equipment] = [
//        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Square Baler", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
//        Equipment(equipmentID: UUID(), equipmentImage: "4.jpeg", name: "Rice Harvester", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1100,realPricePerHour: 1500 , pricePerAcre: 2200, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Gunpura, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
//        Equipment(equipmentID: UUID(), equipmentImage: "2.jpeg", name: "Trailed Sprayers", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1200,realPricePerHour: 1500 , pricePerAcre: 2300, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Dankaur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["2.jpeg","2.jpeg","2.jpeg","2.jpeg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
//        Equipment(equipmentID: UUID(), equipmentImage: "5.jpeg", name: "Harrow", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1300,realPricePerHour: 1500 , pricePerAcre: 2400, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Bisrakh, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["5.jpeg","5.jpeg","5.jpeg","5.jpeg","5.jprg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
//    ]
//    
//    
//        func getAllEquipment() -> [Equipment] {
//            return EquipmentData.equipment //equipment
//        }
//    
//        func getEquipment(byType type: String) -> [Equipment] {
//            return EquipmentData.equipment.filter { $0.type == type } //equipment.filter { $0.type == type }
//        }
//    
//        func getAllReviews() -> [ReviewData] {
//            return EquipmentData.reviews //reviews
//        }
//    
//        func addReview(_ review: ReviewData) {
//            EquipmentData.reviews.append(review) //reviews.append(review)
//        }
//    
//        func getSuggestions() -> [Equipment] {
//            return EquipmentData.suggestionsEquipment //suggestionsEquipment
//        }
//}

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
    private var equipmentList: [Equipment]
    private var reviewList: [ReviewData]
    private var suggestionList: [Equipment]
    
    init() {
        self.equipmentList = EquipmentData.equipment
        self.reviewList = EquipmentData.reviews
        self.suggestionList = EquipmentData.suggestionsEquipment
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
}

class currentUser {
    static let shared = currentUser()
    
    private init() {}
    
    var user: User?
}
