//
//  Equipment Data Model.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import Foundation

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
    
    func isAvailable(on date: Date) -> Bool {
        return date >= availability.startDate && date <= availability.endDate
    }
}

struct Availability {
    var startDate: Date
    var endDate: Date
}

enum coEquipState{
    case available
    case unavailable
}
struct ReviewData{
    var reviewHeading: String
    var reviewDescription: String
    var rating: Double
    
    static var reviews: [ReviewData] = [
        ReviewData(reviewHeading: "Excellent", reviewDescription: "Rented the Swaraj Combine for my rice field, and it worked like a charm! Great fuel efficiency, easy handling, and the rental process was smooth.", rating: 4),
        ReviewData(reviewHeading: "Good", reviewDescription: "Rented the Swaraj Combine for my rice field, and it worked like a charm! Great fuel efficiency, easy handling, and the rental process was smooth.", rating: 3),
        ReviewData(reviewHeading: "Bad", reviewDescription: "The Swaraj Combine was disappointing. It kept breaking down, fuel consumption was high, and I lost valuable time waiting for repairs. Not worth the hassle.", rating: 2),
        ReviewData(reviewHeading: "Very Bad", reviewDescription: "The Swaraj Combine was disappointing. It kept breaking down, fuel consumption was high, and I lost valuable time waiting for repairs. Not worth the hassle.", rating: 1),
        
        ]
}



struct EquipmentMoreImages {
    var images: [String] = ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]
}

class EquipmentData{
    static var equipment: [Equipment] = [
        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Square Baler", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .available, equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg","5.jpeg","6.jpeg","7.jpeg","8.jpeg","9.jpeg","10.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "4.jpeg", name: "Rice Harvester", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1100,realPricePerHour: 1500 , pricePerAcre: 2200, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Gunpura, Grater Noida", coEquipDetail: .available, equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "2.jpeg", name: "Trailed Sprayers", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1200,realPricePerHour: 1500 , pricePerAcre: 2300, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Dankaur, Grater Noida", coEquipDetail: .available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "5.jpeg", name: "Harrow", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1300,realPricePerHour: 1500 , pricePerAcre: 2400, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Bisrakh, Grater Noida", coEquipDetail: .available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "6.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1400,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Alpha2, Grater Noida", coEquipDetail: .available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "7.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        Equipment(equipmentID: UUID(), equipmentImage: "1.jpeg", name: "Tractor", type: "Agricultural", capacity: "1000", availability: Availability(startDate: Date(), endDate: Date()), pricePerHour: 1000,realPricePerHour: 1500 , pricePerAcre: 2100, realPricePerAcre: 2500, providerID: UUID(), rating: 4.5, location: "Murshadpur, Grater Noida", coEquipDetail: .available,equipmentMoreImages: EquipmentMoreImages(images: ["1.jpeg","2.jpeg","3.jpeg","4.jpeg"]), modelYear: "2009", mielage: "15L/ac"),
        
        
       
    ]
    
    
        
//    static var equipmentImages:[EquipmentMoreImages] = [
//        EquipmentMoreImages(images: ["1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg","1.jpeg"])
//    ]
    
}


