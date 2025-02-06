//
//  DataController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 30/01/25.
//

import Foundation


protocol IKisanDataControllerProtocol {
    func getAllEquipment() -> [Equipment]
    func getEquipment(byType type: String) -> [Equipment]
    func getAllReviews() -> [ReviewData]
    func addReview(_ review: ReviewData)
    func getSuggestions() -> [Equipment]
}

//class IKisanDataController: IKisanDataControllerProtocol {
//
//    private var equipmentList: [Equipment] = EquipmentData.equipment
//    private var reviewList: [ReviewData] = EquipmentData.reviews
//    private var suggestionList: [Equipment] = EquipmentData.suggestionsEquipment
//
//    func getAllEquipment() -> [Equipment] {
//        return equipmentList
//    }
//
//    func getEquipment(byType type: String) -> [Equipment] {
//        return equipmentList.filter { $0.type == type }
//    }
//
//    func getAllReviews() -> [ReviewData] {
//        return reviewList
//    }
//
//    func addReview(_ review: ReviewData) {
//        reviewList.append(review)
//    }
//
//    func getSuggestions() -> [Equipment] {
//        return suggestionList
//    }
//}

class EquipmentData{
    static var equipment: [Equipment] = [
        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Square Baler", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "4.jpeg", name: "Rice Harvester", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1100,realPricePerHour: 1500 , pricePerAcre: 2200, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Gunpura, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "2.jpeg", name: "Trailed Sprayers", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1200,realPricePerHour: 1500 , pricePerAcre: 2300, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Dankaur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["2.jpeg","2.jpeg","2.jpeg","2.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "5.jpeg", name: "Harrow", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1300,realPricePerHour: 1500 , pricePerAcre: 2400, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Bisrakh, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["5.jpeg","5.jpeg","5.jpeg","5.jpeg","5.jprg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "6.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1400,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Alpha2, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "7.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
      
    ]
    
    static var reviews: [ReviewData] = [
        ReviewData(reviewHeading: "Excellent", reviewDescription: "Rented the Swaraj Combine for my rice field, and it worked like a charm! Great fuel efficiency, easy handling, and the rental process was smooth.", rating: 4),
        ReviewData(reviewHeading: "Good", reviewDescription: "Rented the Swaraj Combine for my rice field, and it worked like a charm! Great fuel efficiency, easy handling, and the rental process was smooth.", rating: 3),
        ReviewData(reviewHeading: "Bad", reviewDescription: "The Swaraj Combine was disappointing. It kept breaking down, fuel consumption was high, and I lost valuable time waiting for repairs. Not worth the hassle.", rating: 2),
        ReviewData(reviewHeading: "Very Bad", reviewDescription: "The Swaraj Combine was disappointing. It kept breaking down, fuel consumption was high, and I lost valuable time waiting for repairs. Not worth the hassle.", rating: 1),
        
        ]
    static var suggestionsEquipment: [Equipment] = [
        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Square Baler", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
        Equipment(equipmentID: UUID(), equipmentImage: "4.jpeg", name: "Rice Harvester", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1100,realPricePerHour: 1500 , pricePerAcre: 2200, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Gunpura, Grater Noida", coEquipDetail: .Available, equipmentMoreImages: EquipmentMoreImages(images: ["4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
        Equipment(equipmentID: UUID(), equipmentImage: "2.jpeg", name: "Trailed Sprayers", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1200,realPricePerHour: 1500 , pricePerAcre: 2300, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Dankaur, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["2.jpeg","2.jpeg","2.jpeg","2.jpeg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
        Equipment(equipmentID: UUID(), equipmentImage: "5.jpeg", name: "Harrow", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1300,realPricePerHour: 1500 , pricePerAcre: 2400, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Bisrakh, Grater Noida", coEquipDetail: .Available,equipmentMoreImages: EquipmentMoreImages(images: ["5.jpeg","5.jpeg","5.jpeg","5.jpeg","5.jprg"]), modelYear: "2009", mielage: "15L/ac", description: "Available in your Area"),
    ]
}
