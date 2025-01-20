//
//  DMcreateRequest.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/01/25.
//


import Foundation

// Section 1: Equipment Images
struct EquipmentImageData {
    var imageName: String
}

// Section 2: Equipment Names
struct EquipmentNameData {
    var name: String
}

// Section 3: Equipment Details (Image + Name)
struct EquipmentDetailData {
    var imageName: String
    var name: String
}

// Main data class to hold static data for UI
class EquipmentScreenData {
    static var equipmentImages: [EquipmentImageData] = [
        EquipmentImageData(imageName: "tractor"),
        EquipmentImageData(imageName: "plow"),
        EquipmentImageData(imageName: "harvester"),
        EquipmentImageData(imageName: "irrigation")
    ]
    
    static var equipmentNames: [EquipmentNameData] = [
        EquipmentNameData(name: "Tractor"),
        EquipmentNameData(name: "Plow"),
        EquipmentNameData(name: "Harvester"),
        EquipmentNameData(name: "Irrigation System")
    ]
    
    static var equipmentDetails: [EquipmentDetailData] = [
        EquipmentDetailData(imageName: "tractor", name: "Tractor"),
        EquipmentDetailData(imageName: "plow", name: "Plow"),
        EquipmentDetailData(imageName: "harvester", name: "Harvester"),
        EquipmentDetailData(imageName: "irrigation", name: "Irrigation System")
    ]
    
    static var sectionHeaders: [String] = [
        "Equipment Images",
        "Equipment Names",
        "Equipment Details"
    ]
}
