//
//  AgriAssistDataModel.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import Foundation
import UIKit

struct Crop {
    let id: Int
    let name: String
    let imageName: UIImage// URL or local image asset name for the crop
}



struct Equipment {
    let id: UUID
    let name: String
    let type: String // Type of equipment (e.g., Cultivator, Harrow)
    let description: String
    let bestFor: String // Field area, crop type, etc.
    let costPerAcre: Double
    let imageUrl: URL // Equipment image
    let videoUrls: [URL] // Related video URLs for equipment usage
    let rating: Double // Average rating for the equipment
    let reviews: [Review] // List of reviews
}

struct Review {
    let reviewerName: String
    let rating: Double // Rating out of 5
    let comment: String
    let date: Date
}


struct Booking {
    let id: UUID
    let equipment: Equipment
    let date: Date
    let timeSlot: TimeSlot
    let areaInAcres: Double
    let totalCost: Double
    let location: String // Location for the booking
    let host: String // Equipment host
}

enum TimeSlot: String {
    case morning = "Morning"
    case afternoon = "Afternoon"
    case evening = "Evening"
}

struct EquipmentsForCrops {
    var Equipmentsimage:[String]
    var EquipmentsName:[String]
}


