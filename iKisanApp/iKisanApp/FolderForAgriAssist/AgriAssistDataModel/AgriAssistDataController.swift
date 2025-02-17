////
////  EquipmentsForCropsDataSet.swift
////  iKisanApp
////
////  Created by Batch - 1 on 22/01/25.
////
//
//import Foundation
//import UIKit
//
//
////   EquipmentsForCrops(Secondpage)  Data Set
//class EData {
//    static var EquipmentsForCropsData = [
//        // Rice
//        CropCategory(
//            cropName: "Rice",
//            EquipmentsForCrops: "Equipments For Rice",
//            equipments: [
//                EquipmentCategory(
//                    title: "Cultivator",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 1",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"
//),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 2",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 4",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 5",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Harrow",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 1",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 4",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 2",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Seeder",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Thresher",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 6",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Planter",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                )
//            ]
//        ),
//        
//        // Wheat
//        CropCategory(
//            cropName: "Wheat",
//            EquipmentsForCrops: "Equipments For Wheat",
//            equipments: [
//                EquipmentCategory(
//                    title: "Plough",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Seeder",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Thresher",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Harvester",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                )
//            ]
//        ),
//        // oats
//        CropCategory(
//            cropName: "Oats",
//            EquipmentsForCrops: "Equipments For Oats",
//            equipments: [
//                EquipmentCategory(
//                    title: "Planter",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Harvester",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Cultivator",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Sprayer",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                )
//            ]
//        ),
//        
//        // Cotton
//        CropCategory(
//            cropName: "Cotton",
//            EquipmentsForCrops: "Equipments For Cotton",
//            equipments: [
//                EquipmentCategory(
//                    title: "Cultivator",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Planter",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Harvester",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Sprayer",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                )
//            ]
//        ),
//        
//        // Tea
//        CropCategory(
//            cropName: "Tea",
//            EquipmentsForCrops: "Equipments For Tea",
//            equipments: [
//                EquipmentCategory(
//                    title: "Pruner",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Harvester",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Weeder",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Fertilizer Spreader",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                )
//            ]
//        ),
//        
//        // Maize
//        CropCategory(
//            cropName: "Maize",
//            EquipmentsForCrops: "Equipments For Maize",
//            equipments: [
//                EquipmentCategory(
//                    title: "Seeder",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Harvester",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Cultivator",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Sprayer",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                )
//            ]
//        ),
//        
//        // Tobacco
//        CropCategory(
//            cropName: "Tobacco",
//            EquipmentsForCrops: "Equipments For Tobacco",
//            equipments: [
//                EquipmentCategory(
//                    title: "Seeder",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Harvester",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Planter",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Sprayer",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                )
//            ]
//        ),
//        
//        // Sugarcane
//        CropCategory(
//            cropName: "Sugarcane",
//            EquipmentsForCrops: "Equipments For Sugarcane",
//            equipments: [
//                EquipmentCategory(
//                    title: "Planter",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Harvester",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Cultivator",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                ),
//                EquipmentCategory(
//                    title: "Sprayer",
//                    equipmentList: [
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator"),
//                        EquipmentAgri(equipmentType: "Spring Cultivator",
//                                      equipmentName:"Spring Cultivator",
//                                      equipmentImage: "Image 3",
//                                      equipmentLikedBy: "1000",
//                                      equipmentPurpose: "Used for primary tillage in rice fields",
//                                      equipmentBestFor: "Large rice fields over 4 acres",
//                                      equipmentAverageCost: "₹50,000",
//                                      equipmentNeeds: "Tractor with 35+ HP, skilled operator")
//                    ]
//                )
//            ]
//        )
//    ]
//}
//
//
//
//
//
//
//// SelectCrops(FirstPage) dataSet
//var crops: [AgriCrop] = [
//    AgriCrop(id: 1, name: "Rice", imageName: UIImage(named: "Rice") ?? UIImage()),
//    AgriCrop(id: 2, name: "Wheat", imageName: UIImage(named: "Wheat") ?? UIImage()),
//    AgriCrop(id: 3, name: "Oats", imageName: UIImage(named: "Oats") ?? UIImage()),
//    AgriCrop(id: 4, name: "Cotton", imageName: UIImage(named: "Cotton") ?? UIImage()),
//    AgriCrop(id: 5, name: "Tea", imageName: UIImage(named: "Tea") ?? UIImage()),
//    AgriCrop(id: 6, name: "Maize", imageName: UIImage(named: "Maize") ?? UIImage()),
//    AgriCrop(id: 7, name: "Tobacco", imageName: UIImage(named: "Tobacco") ?? UIImage()),
//    AgriCrop(id: 8, name: "Sugarcane", imageName: UIImage(named: "Sugarcane") ?? UIImage())
//]
//
//
//
//
//
//
//
//
//// SameTypeAllEquipments(ThirdPage) DataSet
//var Data = [
//    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
//    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["1","2","harrow","hhaarrooww","herahero"]),
//    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["","cultivater","harrow","hhaarrooww","herahero"]),
//    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle4","cultivater","harrow","hhaarrooww","herahero"]),
//    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle5","","harrow","hhaarrooww","herahero"]),
//    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle6","cultivater","","hhaarrooww","herahero"])
//    
//]
//
//
//
//
//// InfoAboutEquipment(fourthPage)DataSet
//class ScreenData {
//    // Section 1 - Data for Equipment Types (Only one item for Section 1)
//    static var section1Data: [Section1Data] = [
//        Section1Data(equipmentTypeName: "Excavator",
//                     equipmentTypeImage: "Image",
//                     equipmentTypeLikedBy: "1000",
//                     equipmentTypePurpose: "Designed for use in flooded paddy fields.",
//                     equipmentTypeBestFor: "Field area more than 4 acres.Construction",
//                     equipmentTypeAverageCost: "$50,000",
//                     equipmentTypeNeeds: "Operator, Fuel.Field area more than 4 ac. Field more than 4 acres.")
//    ]
//    
//    // Section 2 - Data for Equipment Details (5 items for Section 2)
//    static var section2Data: [Section2Data] = [
//        Section2Data(equipmentName: "Hammer Drill",
//                     equipmentLikedBy: "800",
//                     equipmentImage: "Image"),
//        
//        Section2Data(equipmentName: "Angle Grinder",
//                     equipmentLikedBy: "12",
//                     equipmentImage: "Image 1"),
//        
//        Section2Data(equipmentName: "Welding Machine",
//                     equipmentLikedBy: "150",
//                     equipmentImage: "Image 2"),
//        
//        Section2Data(equipmentName: "Concrete Mixer",
//                     equipmentLikedBy: "2000",
//                     equipmentImage: "Image 3"),
//        
//        Section2Data(equipmentName: "Circular Saw",
//                     equipmentLikedBy: "90",
//                     equipmentImage: "Image 4")
//    ]
//    
//    static var sectionHeaderNames:[String] = [
//        "Type of cultivators",
//        "Similar"
//    ]
//}
//
//
//
//
//
//
//
//
//
//
//
//
//
///////////////////////////////////////
/////
/////
/////
//
//
//
////class EData {
////    static var EquipmentsForCropsData = [
////        // Rice
////        CropCategory(
////            cropName: "Rice",
////            EquipmentsForCrops: "Equipments For Rice",
////            equipments: [
////                EquipmentCategory(
////                    title: "Cultivator",
////                    equipmentList: [
////                        EquipmentAgri(name: "Spring ", imageName: "Image 1"),
////                        EquipmentAgri(name: "Rigid ", imageName: "Image 2"),
////                        EquipmentAgri(name: "Rotary", imageName: "Image 3"),
////                        EquipmentAgri(name: "Power ", imageName: "Image 4"),
////                        EquipmentAgri(name: "Mini", imageName: "Image 5"),
////                        EquipmentAgri(name: "Spring ", imageName: "Image 1")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Harrow",
////                    equipmentList: [
////                        EquipmentAgri(name: "Disc Harrow", imageName: "disc_harrow"),
////                        EquipmentAgri(name: "Spike Tooth Harrow", imageName: "spike_tooth_harrow"),
////                        EquipmentAgri(name: "Chain Harrow", imageName: "chain_harrow"),
////                        EquipmentAgri(name: "Tine Harrow", imageName: "tine_harrow"),
////                        EquipmentAgri(name: "Offset Harrow", imageName: "offset_harrow")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Seeder",
////                    equipmentList: [
////                        EquipmentAgri(name: "Paddy Seeder", imageName: "paddy_seeder"),
////                        EquipmentAgri(name: "Direct Seeder", imageName: "direct_seeder"),
////                        EquipmentAgri(name: "Drum Seeder", imageName: "drum_seeder"),
////                        EquipmentAgri(name: "Automatic Seeder", imageName: "automatic_seeder"),
////                        EquipmentAgri(name: "Row Seeder", imageName: "row_seeder")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Thresher",
////                    equipmentList: [
////                        EquipmentAgri(name: "Axial Thresher", imageName: "axial_thresher"),
////                        EquipmentAgri(name: "Spike Tooth Thresher", imageName: "spike_tooth_thresher"),
////                        EquipmentAgri(name: "Multi-crop Thresher", imageName: "multi_crop_thresher"),
////                        EquipmentAgri(name: "Paddy Thresher", imageName: "paddy_thresher"),
////                        EquipmentAgri(name: "Rotary Thresher", imageName: "rotary_thresher")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Planter",
////                    equipmentList: [
////                        EquipmentAgri(name: "Row Planter", imageName: "row_planter"),
////                        EquipmentAgri(name: "Drill Planter", imageName: "drill_planter"),
////                        EquipmentAgri(name: "Broadcast Planter", imageName: "broadcast_planter"),
////                        EquipmentAgri(name: "Precision Planter", imageName: "precision_planter"),
////                        EquipmentAgri(name: "Manual Planter", imageName: "manual_planter")
////                    ]
////                )
////            ]
////        ),
////        
////        // Wheat
////        CropCategory(
////            cropName: "Wheat",
////            EquipmentsForCrops: "Equipments For Wheat",
////            equipments: [
////                EquipmentCategory(
////                    title: "Plough",
////                    equipmentList: [
////                        EquipmentAgri(name: "Mouldboard Plough", imageName: "mouldboard_plough"),
////                        EquipmentAgri(name: "Reversible Plough", imageName: "reversible_plough"),
////                        EquipmentAgri(name: "Chisel Plough", imageName: "chisel_plough"),
////                        EquipmentAgri(name: "Disc Plough", imageName: "disc_plough")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Seeder",
////                    equipmentList: [
////                        EquipmentAgri(name: "Seed Drill", imageName: "seed_drill"),
////                        EquipmentAgri(name: "Broadcast Seeder", imageName: "broadcast_seeder"),
////                        EquipmentAgri(name: "Air Seeder", imageName: "air_seeder"),
////                        EquipmentAgri(name: "Precision Seeder", imageName: "precision_seeder")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Thresher",
////                    equipmentList: [
////                        EquipmentAgri(name: "Wheat Thresher", imageName: "wheat_thresher"),
////                        EquipmentAgri(name: "Multi-crop Thresher", imageName: "multi_crop_thresher"),
////                        EquipmentAgri(name: "Axial Thresher", imageName: "axial_thresher"),
////                        EquipmentAgri(name: "Spike Tooth Thresher", imageName: "spike_tooth_thresher")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Harvester",
////                    equipmentList: [
////                        EquipmentAgri(name: "Combine Harvester", imageName: "combine_harvester"),
////                        EquipmentAgri(name: "Self-Propelled Harvester", imageName: "self_propelled_harvester"),
////                        EquipmentAgri(name: "Reaper Harvester", imageName: "reaper_harvester"),
////                        EquipmentAgri(name: "Multi-crop Harvester", imageName: "multi_crop_harvester")
////                    ]
////                )
////            ]
////        ),
////        // oats
////        CropCategory(
////            cropName: "Oats",
////            EquipmentsForCrops: "Equipments For Oats",
////            equipments: [
////                EquipmentCategory(
////                    title: "Planter",
////                    equipmentList: [
////                        EquipmentAgri(name: "Sugarcane Planter", imageName: "sugarcane_planter"),
////                        EquipmentAgri(name: "Row Sugarcane Planter", imageName: "row_sugarcane_planter"),
////                        EquipmentAgri(name: "Automatic Sugarcane Planter", imageName: "automatic_sugarcane_planter"),
////                        EquipmentAgri(name: "Manual Sugarcane Planter", imageName: "manual_sugarcane_planter")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Harvester",
////                    equipmentList: [
////                        EquipmentAgri(name: "Sugarcane Harvester", imageName: "sugarcane_harvester"),
////                        EquipmentAgri(name: "Chopper Harvester", imageName: "chopper_harvester"),
////                        EquipmentAgri(name: "Self-Propelled Harvester", imageName: "self_propelled_sugarcane_harvester"),
////                        EquipmentAgri(name: "Manual Harvester", imageName: "manual_sugarcane_harvester")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Cultivator",
////                    equipmentList: [
////                        EquipmentAgri(name: "Sugarcane Cultivator", imageName: "sugarcane_cultivator"),
////                        EquipmentAgri(name: "Tractor-Mounted Cultivator", imageName: "tractor_cultivator"),
////                        EquipmentAgri(name: "Handheld Cultivator", imageName: "handheld_sugarcane_cultivator"),
////                        EquipmentAgri(name: "Rotary Cultivator", imageName: "rotary_sugarcane_cultivator")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Sprayer",
////                    equipmentList: [
////                        EquipmentAgri(name: "Boom Sprayer", imageName: "boom_sprayer"),
////                        EquipmentAgri(name: "Backpack Sprayer", imageName: "backpack_sprayer"),
////                        EquipmentAgri(name: "Field Sprayer", imageName: "field_sprayer"),
////                        EquipmentAgri(name: "Aerial Sprayer", imageName: "aerial_sprayer")
////                    ]
////                )
////            ]
////        ),
////        
////        // Cotton
////        CropCategory(
////            cropName: "Cotton",
////            EquipmentsForCrops: "Equipments For Cotton",
////            equipments: [
////                EquipmentCategory(
////                    title: "Cultivator",
////                    equipmentList: [
////                        EquipmentAgri(name: "Shovel Cultivator", imageName: "shovel_cultivator"),
////                        EquipmentAgri(name: "Tine Cultivator", imageName: "tine_cultivator"),
////                        EquipmentAgri(name: "Rotary Cultivator", imageName: "rotary_cultivator"),
////                        EquipmentAgri(name: "Mini Cultivator", imageName: "mini_cultivator")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Planter",
////                    equipmentList: [
////                        EquipmentAgri(name: "Cotton Planter", imageName: "cotton_planter"),
////                        EquipmentAgri(name: "Air Seed Planter", imageName: "air_seed_planter"),
////                        EquipmentAgri(name: "Drill Planter", imageName: "drill_planter"),
////                        EquipmentAgri(name: "Precision Planter", imageName: "precision_planter")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Harvester",
////                    equipmentList: [
////                        EquipmentAgri(name: "Cotton Picker", imageName: "cotton_picker"),
////                        EquipmentAgri(name: "Stripper Harvester", imageName: "stripper_harvester"),
////                        EquipmentAgri(name: "Combine Harvester", imageName: "combine_harvester"),
////                        EquipmentAgri(name: "Self-Propelled Harvester", imageName: "self_propelled_harvester")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Sprayer",
////                    equipmentList: [
////                        EquipmentAgri(name: "Boom Sprayer", imageName: "boom_sprayer"),
////                        EquipmentAgri(name: "Backpack Sprayer", imageName: "backpack_sprayer"),
////                        EquipmentAgri(name: "Field Sprayer", imageName: "field_sprayer"),
////                        EquipmentAgri(name: "Aerial Sprayer", imageName: "aerial_sprayer")
////                    ]
////                )
////            ]
////        ),
////        
////        // Tea
////        CropCategory(
////            cropName: "Tea",
////            EquipmentsForCrops: "Equipments For Tea",
////            equipments: [
////                EquipmentCategory(
////                    title: "Pruner",
////                    equipmentList: [
////                        EquipmentAgri(name: "Tea Pruner", imageName: "tea_pruner"),
////                        EquipmentAgri(name: "Handheld Pruner", imageName: "handheld_pruner"),
////                        EquipmentAgri(name: "Hydraulic Pruner", imageName: "hydraulic_pruner"),
////                        EquipmentAgri(name: "Battery Operated Pruner", imageName: "battery_pruner")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Harvester",
////                    equipmentList: [
////                        EquipmentAgri(name: "Tea Plucking Machine", imageName: "tea_plucker"),
////                        EquipmentAgri(name: "Shear Harvester", imageName: "shear_harvester"),
////                        EquipmentAgri(name: "Manual Harvester", imageName: "manual_tea_harvester"),
////                        EquipmentAgri(name: "Self Propelled Harvester", imageName: "self_propelled_tea_harvester")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Weeder",
////                    equipmentList: [
////                        EquipmentAgri(name: "Mechanical Weeder", imageName: "mechanical_weeder"),
////                        EquipmentAgri(name: "Manual Weeder", imageName: "manual_weeder"),
////                        EquipmentAgri(name: "Rotary Weeder", imageName: "rotary_weeder"),
////                        EquipmentAgri(name: "Sprayer Weeder", imageName: "sprayer_weeder")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Fertilizer Spreader",
////                    equipmentList: [
////                        EquipmentAgri(name: "Granular Fertilizer Spreader", imageName: "granular_fertilizer_spreader"),
////                        EquipmentAgri(name: "Liquid Fertilizer Spreader", imageName: "liquid_fertilizer_spreader"),
////                        EquipmentAgri(name: "Handheld Fertilizer Spreader", imageName: "handheld_fertilizer_spreader"),
////                        EquipmentAgri(name: "Motorized Fertilizer Spreader", imageName: "motorized_fertilizer_spreader")
////                    ]
////                )
////            ]
////        ),
////        
////        // Maize
////        CropCategory(
////            cropName: "Maize",
////            EquipmentsForCrops: "Equipments For Maize",
////            equipments: [
////                EquipmentCategory(
////                    title: "Seeder",
////                    equipmentList: [
////                        EquipmentAgri(name: "Corn Planter", imageName: "corn_planter"),
////                        EquipmentAgri(name: "Row Crop Planter", imageName: "row_crop_planter"),
////                        EquipmentAgri(name: "Drill Planter", imageName: "drill_planter"),
////                        EquipmentAgri(name: "Precision Planter", imageName: "precision_planter")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Harvester",
////                    equipmentList: [
////                        EquipmentAgri(name: "Corn Harvester", imageName: "corn_harvester"),
////                        EquipmentAgri(name: "Silage Harvester", imageName: "silage_harvester"),
////                        EquipmentAgri(name: "Combine Harvester", imageName: "combine_harvester"),
////                        EquipmentAgri(name: "Self-Propelled Harvester", imageName: "self_propelled_harvester")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Cultivator",
////                    equipmentList: [
////                        EquipmentAgri(name: "Spring Cultivator", imageName: "spring_cultivator"),
////                        EquipmentAgri(name: "Rigid Cultivator", imageName: "rigid_cultivator"),
////                        EquipmentAgri(name: "Rotary Cultivator", imageName: "rotary_cultivator"),
////                        EquipmentAgri(name: "Power Cultivator", imageName: "power_cultivator")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Sprayer",
////                    equipmentList: [
////                        EquipmentAgri(name: "Boom Sprayer", imageName: "boom_sprayer"),
////                        EquipmentAgri(name: "Backpack Sprayer", imageName: "backpack_sprayer"),
////                        EquipmentAgri(name: "Field Sprayer", imageName: "field_sprayer"),
////                        EquipmentAgri(name: "Aerial Sprayer", imageName: "aerial_sprayer")
////                    ]
////                )
////            ]
////        ),
////        
////        // Tobacco
////        CropCategory(
////            cropName: "Tobacco",
////            EquipmentsForCrops: "Equipments For Tobacco",
////            equipments: [
////                EquipmentCategory(
////                    title: "Seeder",
////                    equipmentList: [
////                        EquipmentAgri(name: "Tobacco Seeder", imageName: "tobacco_seeder"),
////                        EquipmentAgri(name: "Nursery Seeder", imageName: "nursery_seeder"),
////                        EquipmentAgri(name: "Drum Seeder", imageName: "drum_seeder"),
////                        EquipmentAgri(name: "Broadcast Seeder", imageName: "broadcast_seeder")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Harvester",
////                    equipmentList: [
////                        EquipmentAgri(name: "Tobacco Harvester", imageName: "tobacco_harvester"),
////                        EquipmentAgri(name: "Manual Harvester", imageName: "manual_harvester"),
////                        EquipmentAgri(name: "Self-Propelled Harvester", imageName: "self_propelled_tobacco_harvester"),
////                        EquipmentAgri(name: "Combine Harvester", imageName: "combine_tobacco_harvester")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Planter",
////                    equipmentList: [
////                        EquipmentAgri(name: "Tobacco Planter", imageName: "tobacco_planter"),
////                        EquipmentAgri(name: "Air Seed Planter", imageName: "air_seed_planter"),
////                        EquipmentAgri(name: "Precision Planter", imageName: "precision_planter"),
////                        EquipmentAgri(name: "Drill Planter", imageName: "drill_planter")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Sprayer",
////                    equipmentList: [
////                        EquipmentAgri(name: "Boom Sprayer", imageName: "boom_sprayer"),
////                        EquipmentAgri(name: "Handheld Sprayer", imageName: "handheld_sprayer"),
////                        EquipmentAgri(name: "Field Sprayer", imageName: "field_sprayer"),
////                        EquipmentAgri(name: "Aerial Sprayer", imageName: "aerial_sprayer")
////                    ]
////                )
////            ]
////        ),
////        
////        // Sugarcane
////        CropCategory(
////            cropName: "Sugarcane",
////            EquipmentsForCrops: "Equipments For Sugarcane",
////            equipments: [
////                EquipmentCategory(
////                    title: "Planter",
////                    equipmentList: [
////                        EquipmentAgri(name: "Sugarcane Planter", imageName: "sugarcane_planter"),
////                        EquipmentAgri(name: "Row Sugarcane Planter", imageName: "row_sugarcane_planter"),
////                        EquipmentAgri(name: "Automatic Sugarcane Planter", imageName: "automatic_sugarcane_planter"),
////                        EquipmentAgri(name: "Manual Sugarcane Planter", imageName: "manual_sugarcane_planter")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Harvester",
////                    equipmentList: [
////                        EquipmentAgri(name: "Sugarcane Harvester", imageName: "sugarcane_harvester"),
////                        EquipmentAgri(name: "Chopper Harvester", imageName: "chopper_harvester"),
////                        EquipmentAgri(name: "Self-Propelled Harvester", imageName: "self_propelled_sugarcane_harvester"),
////                        EquipmentAgri(name: "Manual Harvester", imageName: "manual_sugarcane_harvester")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Cultivator",
////                    equipmentList: [
////                        EquipmentAgri(name: "Sugarcane Cultivator", imageName: "sugarcane_cultivator"),
////                        EquipmentAgri(name: "Tractor-Mounted Cultivator", imageName: "tractor_cultivator"),
////                        EquipmentAgri(name: "Handheld Cultivator", imageName: "handheld_sugarcane_cultivator"),
////                        EquipmentAgri(name: "Rotary Cultivator", imageName: "rotary_sugarcane_cultivator")
////                    ]
////                ),
////                EquipmentCategory(
////                    title: "Sprayer",
////                    equipmentList: [
////                        EquipmentAgri(name: "Boom Sprayer", imageName: "boom_sprayer"),
////                        EquipmentAgri(name: "Backpack Sprayer", imageName: "backpack_sprayer"),
////                        EquipmentAgri(name: "Field Sprayer", imageName: "field_sprayer"),
////                        EquipmentAgri(name: "Aerial Sprayer", imageName: "aerial_sprayer")
////                    ]
////                )
////            ]
////        )
////    ]
////}
////
////
////
////// EquipmentsForCrops(Secondpage)  Data Set ye romove hoga jab uper wale data set me se 3D array ka data fatch hojaega
//////var EqData = [
//////    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
//////    EquipmentsForCrops(Equipmentsimage: ["Image","Image 3","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
//////    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
//////    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
//////    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"]),
//////    EquipmentsForCrops(Equipmentsimage: ["Image","Image 2","Image 3","Image 4","Image"],EquipmentsName: ["paddle weel","cultivater","harrow","hhaarrooww","herahero"])
//////]
////
////
