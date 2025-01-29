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



