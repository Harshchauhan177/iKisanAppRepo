//
//  AgriAssistDataModel.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import Foundation
import UIKit


struct AgriCrop {
    let id: Int
    let name: String
    let imageName: UIImage// URL or local image asset name for the crop
}
struct EquipmentsForCrops {
    var Equipmentsimage:[String]
    var EquipmentsName:[String]
}

// For page two of AgriAssist
struct EquipmentAgri {
    var name: String
    var imageName: String
}
struct CropCategory {
    var cropName: String
    var EquipmentsForCrops : String
    var equipments: [EquipmentCategory]
}
struct EquipmentCategory {
    var title: String
    var equipmentList: [EquipmentAgri]
}


// InfoAboutEquipment(fourthPage)DataModel

/// Section 1 Data Model for Equipment Types ///
struct Section1Data {
    var equipmentTypeName: String
    var equipmentTypeImage: String
    var equipmentTypeLikedBy: String
    var equipmentTypePurpose: String
    var equipmentTypeBestFor: String
    var equipmentTypeAverageCost: String
    var equipmentTypeNeeds: String
}

// Section 2 Data Model for Equipment Details
struct Section2Data {
    var equipmentName: String
    var equipmentLikedBy: String
    var equipmentImage: String
//    var equipmentDescription: String
}
