//
//  InfoAboutEquipmentDataModel.swift
//  iKisanApp
//
//  Created by Batch - 1 on 21/01/25.
//

//import Foundation
//struct Section1Data {
//    var EquipmentTypeName:String
//    var EquipmentTypeImage:String
//    var EquipmentTypeLikedBy:String
//    var EquipmentTypePurpose:String
//    var EquipmentTypeBestfor:String
//    var EquipmentTypeAveragecost:String
//    var EquipmentTypeNeeds:String
//}
//struct Section2Data {
//    var EquipmentName:String
//    var EquipmentLikedBy:String
//    var EquipmentImage:String
//    var EquipmentDescription:String
//}
//
//class ScreenData {
//    // Section 1 - Data for Equipment Types (Only one item for Section 1)
//    static var section1Data: [Section1Data] = [
//        Section1Data(equipmentTypeName: "Excavator", equipmentTypeImage: "excavator_image", equipmentTypeLikedBy: "1000", equipmentTypePurpose: "Digging", equipmentTypeBestFor: "Construction", equipmentTypeAverageCost: "$50,000", equipmentTypeNeeds: "Operator and Fuel")
//    ]
//    
//    // Section 2 - Data for Equipment Details (5 items for Section 2)
//    static var section2Data: [Section2Data] = [
//        Section2Data(equipmentName: "Hammer Drill", equipmentLikedBy: "800", equipmentImage: "hammer_drill_image", equipmentDescription: "Used for drilling tough surfaces."),
//        Section2Data(equipmentName: "Angle Grinder", equipmentLikedBy: "1200", equipmentImage: "angle_grinder_image", equipmentDescription: "Used for grinding metal surfaces."),
//        Section2Data(equipmentName: "Welding Machine", equipmentLikedBy: "1500", equipmentImage: "welding_machine_image", equipmentDescription: "Used for welding metal parts together."),
//        Section2Data(equipmentName: "Concrete Mixer", equipmentLikedBy: "2000", equipmentImage: "concrete_mixer_image", equipmentDescription: "Used to mix concrete in construction."),
//        Section2Data(equipmentName: "Circular Saw", equipmentLikedBy: "900", equipmentImage: "circular_saw_image", equipmentDescription: "Used for cutting wood and other materials.")
//    ]
//    
////    static var sectionHeaderNames: [String] = [
////        "Equipment Types",   // Header for Section 1
////        "Equipment Details", // Header for Section 2
////        "Full Equipment Information" // Header for Section 3
////    ]
//}
import Foundation

// Section 1 Data Model for Equipment Types
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

class ScreenData {
    // Section 1 - Data for Equipment Types (Only one item for Section 1)
    static var section1Data: [Section1Data] = [
        Section1Data(equipmentTypeName: "Excavator",
                     equipmentTypeImage: "Image",
                     equipmentTypeLikedBy: "1000",
                     equipmentTypePurpose: "Designed for use in flooded paddy fields.",
                     equipmentTypeBestFor: "Field area more than 4 acres.Construction",
                     equipmentTypeAverageCost: "$50,000",
                     equipmentTypeNeeds: "Operator, Fuel.Field area more than 4 ac. Field more than 4 acres.")
    ]
    
    // Section 2 - Data for Equipment Details (5 items for Section 2)
    static var section2Data: [Section2Data] = [
        Section2Data(equipmentName: "Hammer Drill",
                     equipmentLikedBy: "800",
                     equipmentImage: "Image"),
        
        Section2Data(equipmentName: "Angle Grinder",
                     equipmentLikedBy: "12",
                     equipmentImage: "Image 1"),
        
        Section2Data(equipmentName: "Welding Machine",
                     equipmentLikedBy: "150",
                     equipmentImage: "Image 2"),
        
        Section2Data(equipmentName: "Concrete Mixer",
                     equipmentLikedBy: "2000",
                     equipmentImage: "Image 3"),
        
        Section2Data(equipmentName: "Circular Saw",
                     equipmentLikedBy: "90",
                     equipmentImage: "Image 4")
    ]
    
    static var sectionHeaderNames:[String] = [
        "Type of cultivators",
        "Similar"
    ]
}
