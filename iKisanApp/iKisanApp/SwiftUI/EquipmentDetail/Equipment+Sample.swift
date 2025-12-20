//
//  Equipment+Sample.swift
//  iKisanApp
//
//  Sample equipment data for SwiftUI previews
//

import Foundation

extension Equipment {
    static var sampleEquipment: Equipment {
        var equipment = Equipment(
            equipmentID: UUID(),
            equipmentImage: "Image 1",
            name: "Square Balers",
            type: "Baler",
            capacity: "200 kg/hr",
            pricePerHour: 500,
            realPricePerHour: 650,
            pricePerAcre: 1200,
            realPricePerAcre: 1500,
            providerID: UUID(),
            rating: 4.5,
            location: "Prayagraj, UP",
            coEquipDetail: .Available,
            modelYear: "2022",
            mielage: "12 km/L",
            description: "High-performance square baler perfect for hay and straw baling. Well-maintained and reliable equipment.",
            isRecommended: true,
            providerName: "Ramesh Kumar",
            preBookingStatus: nil,
            availabilityStartDate: Date(),
            availabilityEndDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()) ?? Date()
        )
        
        // Add more images
        equipment.equipmentMoreImages = EquipmentMoreImages(images: [
            "Image 2",
            "Image 3",
            "Image 4",
            "Image 5",
            "Image 6",
            "Image 7"
        ])
        
        return equipment
    }
}
