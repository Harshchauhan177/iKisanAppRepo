//
//  Crop Data Model.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import Foundation

struct Crop {
    let cropID: UUID
    var name: String
    var season: Season
    var equipmentRecommendations: [UUID]
}

enum Season: String {
    case kharif = "Kharif"
    case rabi = "Rabi"
    case zaid = "Zaid"
}
