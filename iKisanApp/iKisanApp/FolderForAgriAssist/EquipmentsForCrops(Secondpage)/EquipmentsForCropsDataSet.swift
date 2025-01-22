//
//  EquipmentsForCropsDataSet.swift
//  iKisanApp
//
//  Created by Batch - 1 on 22/01/25.
//

import Foundation

struct Equipment {
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
    var equipmentList: [Equipment]
}


class eData {
    static var EquipmentsForCropsData = [
        // Rice
        CropCategory(
            cropName: "Rice",
            EquipmentsForCrops: "Equipments For Rice",
            equipments: [
                EquipmentCategory(
                    title: "Cultivator",
                    equipmentList: [
                        Equipment(name: "Spring Cultivator", imageName: "spring_cultivator"),
                        Equipment(name: "Rigid Cultivator", imageName: "rigid_cultivator"),
                        Equipment(name: "Rotary Cultivator", imageName: "rotary_cultivator"),
                        Equipment(name: "Power Cultivator", imageName: "power_cultivator"),
                        Equipment(name: "Mini Cultivator", imageName: "mini_cultivator")
                    ]
                ),
                EquipmentCategory(
                    title: "Harrow",
                    equipmentList: [
                        Equipment(name: "Disc Harrow", imageName: "disc_harrow"),
                        Equipment(name: "Spike Tooth Harrow", imageName: "spike_tooth_harrow"),
                        Equipment(name: "Chain Harrow", imageName: "chain_harrow"),
                        Equipment(name: "Tine Harrow", imageName: "tine_harrow"),
                        Equipment(name: "Offset Harrow", imageName: "offset_harrow")
                    ]
                ),
                EquipmentCategory(
                    title: "Seeder",
                    equipmentList: [
                        Equipment(name: "Paddy Seeder", imageName: "paddy_seeder"),
                        Equipment(name: "Direct Seeder", imageName: "direct_seeder"),
                        Equipment(name: "Drum Seeder", imageName: "drum_seeder"),
                        Equipment(name: "Automatic Seeder", imageName: "automatic_seeder"),
                        Equipment(name: "Row Seeder", imageName: "row_seeder")
                    ]
                ),
                EquipmentCategory(
                    title: "Thresher",
                    equipmentList: [
                        Equipment(name: "Axial Thresher", imageName: "axial_thresher"),
                        Equipment(name: "Spike Tooth Thresher", imageName: "spike_tooth_thresher"),
                        Equipment(name: "Multi-crop Thresher", imageName: "multi_crop_thresher"),
                        Equipment(name: "Paddy Thresher", imageName: "paddy_thresher"),
                        Equipment(name: "Rotary Thresher", imageName: "rotary_thresher")
                    ]
                ),
                EquipmentCategory(
                    title: "Planter",
                    equipmentList: [
                        Equipment(name: "Row Planter", imageName: "row_planter"),
                        Equipment(name: "Drill Planter", imageName: "drill_planter"),
                        Equipment(name: "Broadcast Planter", imageName: "broadcast_planter"),
                        Equipment(name: "Precision Planter", imageName: "precision_planter"),
                        Equipment(name: "Manual Planter", imageName: "manual_planter")
                    ]
                )
            ]
        ),
        
        // Wheat
        CropCategory(
            cropName: "Wheat",
            EquipmentsForCrops: "Equipments For Wheat",
            equipments: [
                EquipmentCategory(
                    title: "Plough",
                    equipmentList: [
                        Equipment(name: "Mouldboard Plough", imageName: "mouldboard_plough"),
                        Equipment(name: "Reversible Plough", imageName: "reversible_plough"),
                        Equipment(name: "Chisel Plough", imageName: "chisel_plough"),
                        Equipment(name: "Disc Plough", imageName: "disc_plough")
                    ]
                ),
                EquipmentCategory(
                    title: "Seeder",
                    equipmentList: [
                        Equipment(name: "Seed Drill", imageName: "seed_drill"),
                        Equipment(name: "Broadcast Seeder", imageName: "broadcast_seeder"),
                        Equipment(name: "Air Seeder", imageName: "air_seeder"),
                        Equipment(name: "Precision Seeder", imageName: "precision_seeder")
                    ]
                ),
                EquipmentCategory(
                    title: "Thresher",
                    equipmentList: [
                        Equipment(name: "Wheat Thresher", imageName: "wheat_thresher"),
                        Equipment(name: "Multi-crop Thresher", imageName: "multi_crop_thresher"),
                        Equipment(name: "Axial Thresher", imageName: "axial_thresher"),
                        Equipment(name: "Spike Tooth Thresher", imageName: "spike_tooth_thresher")
                    ]
                ),
                EquipmentCategory(
                    title: "Harvester",
                    equipmentList: [
                        Equipment(name: "Combine Harvester", imageName: "combine_harvester"),
                        Equipment(name: "Self-Propelled Harvester", imageName: "self_propelled_harvester"),
                        Equipment(name: "Reaper Harvester", imageName: "reaper_harvester"),
                        Equipment(name: "Multi-crop Harvester", imageName: "multi_crop_harvester")
                    ]
                )
            ]
        ),
        // oats
        CropCategory(
            cropName: "Oats",
            EquipmentsForCrops: "Equipments For Oats",
            equipments: [
                EquipmentCategory(
                    title: "Planter",
                    equipmentList: [
                        Equipment(name: "Sugarcane Planter", imageName: "sugarcane_planter"),
                        Equipment(name: "Row Sugarcane Planter", imageName: "row_sugarcane_planter"),
                        Equipment(name: "Automatic Sugarcane Planter", imageName: "automatic_sugarcane_planter"),
                        Equipment(name: "Manual Sugarcane Planter", imageName: "manual_sugarcane_planter")
                    ]
                ),
                EquipmentCategory(
                    title: "Harvester",
                    equipmentList: [
                        Equipment(name: "Sugarcane Harvester", imageName: "sugarcane_harvester"),
                        Equipment(name: "Chopper Harvester", imageName: "chopper_harvester"),
                        Equipment(name: "Self-Propelled Harvester", imageName: "self_propelled_sugarcane_harvester"),
                        Equipment(name: "Manual Harvester", imageName: "manual_sugarcane_harvester")
                    ]
                ),
                EquipmentCategory(
                    title: "Cultivator",
                    equipmentList: [
                        Equipment(name: "Sugarcane Cultivator", imageName: "sugarcane_cultivator"),
                        Equipment(name: "Tractor-Mounted Cultivator", imageName: "tractor_cultivator"),
                        Equipment(name: "Handheld Cultivator", imageName: "handheld_sugarcane_cultivator"),
                        Equipment(name: "Rotary Cultivator", imageName: "rotary_sugarcane_cultivator")
                    ]
                ),
                EquipmentCategory(
                    title: "Sprayer",
                    equipmentList: [
                        Equipment(name: "Boom Sprayer", imageName: "boom_sprayer"),
                        Equipment(name: "Backpack Sprayer", imageName: "backpack_sprayer"),
                        Equipment(name: "Field Sprayer", imageName: "field_sprayer"),
                        Equipment(name: "Aerial Sprayer", imageName: "aerial_sprayer")
                    ]
                )
            ]
        ),
        
        // Cotton
        CropCategory(
            cropName: "Cotton",
            EquipmentsForCrops: "Equipments For Cotton",
            equipments: [
                EquipmentCategory(
                    title: "Cultivator",
                    equipmentList: [
                        Equipment(name: "Shovel Cultivator", imageName: "shovel_cultivator"),
                        Equipment(name: "Tine Cultivator", imageName: "tine_cultivator"),
                        Equipment(name: "Rotary Cultivator", imageName: "rotary_cultivator"),
                        Equipment(name: "Mini Cultivator", imageName: "mini_cultivator")
                    ]
                ),
                EquipmentCategory(
                    title: "Planter",
                    equipmentList: [
                        Equipment(name: "Cotton Planter", imageName: "cotton_planter"),
                        Equipment(name: "Air Seed Planter", imageName: "air_seed_planter"),
                        Equipment(name: "Drill Planter", imageName: "drill_planter"),
                        Equipment(name: "Precision Planter", imageName: "precision_planter")
                    ]
                ),
                EquipmentCategory(
                    title: "Harvester",
                    equipmentList: [
                        Equipment(name: "Cotton Picker", imageName: "cotton_picker"),
                        Equipment(name: "Stripper Harvester", imageName: "stripper_harvester"),
                        Equipment(name: "Combine Harvester", imageName: "combine_harvester"),
                        Equipment(name: "Self-Propelled Harvester", imageName: "self_propelled_harvester")
                    ]
                ),
                EquipmentCategory(
                    title: "Sprayer",
                    equipmentList: [
                        Equipment(name: "Boom Sprayer", imageName: "boom_sprayer"),
                        Equipment(name: "Backpack Sprayer", imageName: "backpack_sprayer"),
                        Equipment(name: "Field Sprayer", imageName: "field_sprayer"),
                        Equipment(name: "Aerial Sprayer", imageName: "aerial_sprayer")
                    ]
                )
            ]
        ),
        
        // Tea
        CropCategory(
            cropName: "Tea",
            EquipmentsForCrops: "Equipments For Tea",
            equipments: [
                EquipmentCategory(
                    title: "Pruner",
                    equipmentList: [
                        Equipment(name: "Tea Pruner", imageName: "tea_pruner"),
                        Equipment(name: "Handheld Pruner", imageName: "handheld_pruner"),
                        Equipment(name: "Hydraulic Pruner", imageName: "hydraulic_pruner"),
                        Equipment(name: "Battery Operated Pruner", imageName: "battery_pruner")
                    ]
                ),
                EquipmentCategory(
                    title: "Harvester",
                    equipmentList: [
                        Equipment(name: "Tea Plucking Machine", imageName: "tea_plucker"),
                        Equipment(name: "Shear Harvester", imageName: "shear_harvester"),
                        Equipment(name: "Manual Harvester", imageName: "manual_tea_harvester"),
                        Equipment(name: "Self Propelled Harvester", imageName: "self_propelled_tea_harvester")
                    ]
                ),
                EquipmentCategory(
                    title: "Weeder",
                    equipmentList: [
                        Equipment(name: "Mechanical Weeder", imageName: "mechanical_weeder"),
                        Equipment(name: "Manual Weeder", imageName: "manual_weeder"),
                        Equipment(name: "Rotary Weeder", imageName: "rotary_weeder"),
                        Equipment(name: "Sprayer Weeder", imageName: "sprayer_weeder")
                    ]
                ),
                EquipmentCategory(
                    title: "Fertilizer Spreader",
                    equipmentList: [
                        Equipment(name: "Granular Fertilizer Spreader", imageName: "granular_fertilizer_spreader"),
                        Equipment(name: "Liquid Fertilizer Spreader", imageName: "liquid_fertilizer_spreader"),
                        Equipment(name: "Handheld Fertilizer Spreader", imageName: "handheld_fertilizer_spreader"),
                        Equipment(name: "Motorized Fertilizer Spreader", imageName: "motorized_fertilizer_spreader")
                    ]
                )
            ]
        ),
        
        // Maize
        CropCategory(
            cropName: "Maize",
            EquipmentsForCrops: "Equipments For Maize",
            equipments: [
                EquipmentCategory(
                    title: "Seeder",
                    equipmentList: [
                        Equipment(name: "Corn Planter", imageName: "corn_planter"),
                        Equipment(name: "Row Crop Planter", imageName: "row_crop_planter"),
                        Equipment(name: "Drill Planter", imageName: "drill_planter"),
                        Equipment(name: "Precision Planter", imageName: "precision_planter")
                    ]
                ),
                EquipmentCategory(
                    title: "Harvester",
                    equipmentList: [
                        Equipment(name: "Corn Harvester", imageName: "corn_harvester"),
                        Equipment(name: "Silage Harvester", imageName: "silage_harvester"),
                        Equipment(name: "Combine Harvester", imageName: "combine_harvester"),
                        Equipment(name: "Self-Propelled Harvester", imageName: "self_propelled_harvester")
                    ]
                ),
                EquipmentCategory(
                    title: "Cultivator",
                    equipmentList: [
                        Equipment(name: "Spring Cultivator", imageName: "spring_cultivator"),
                        Equipment(name: "Rigid Cultivator", imageName: "rigid_cultivator"),
                        Equipment(name: "Rotary Cultivator", imageName: "rotary_cultivator"),
                        Equipment(name: "Power Cultivator", imageName: "power_cultivator")
                    ]
                ),
                EquipmentCategory(
                    title: "Sprayer",
                    equipmentList: [
                        Equipment(name: "Boom Sprayer", imageName: "boom_sprayer"),
                        Equipment(name: "Backpack Sprayer", imageName: "backpack_sprayer"),
                        Equipment(name: "Field Sprayer", imageName: "field_sprayer"),
                        Equipment(name: "Aerial Sprayer", imageName: "aerial_sprayer")
                    ]
                )
            ]
        ),
        
        // Tobacco
        CropCategory(
            cropName: "Tobacco",
            EquipmentsForCrops: "Equipments For Tobacco",
            equipments: [
                EquipmentCategory(
                    title: "Seeder",
                    equipmentList: [
                        Equipment(name: "Tobacco Seeder", imageName: "tobacco_seeder"),
                        Equipment(name: "Nursery Seeder", imageName: "nursery_seeder"),
                        Equipment(name: "Drum Seeder", imageName: "drum_seeder"),
                        Equipment(name: "Broadcast Seeder", imageName: "broadcast_seeder")
                    ]
                ),
                EquipmentCategory(
                    title: "Harvester",
                    equipmentList: [
                        Equipment(name: "Tobacco Harvester", imageName: "tobacco_harvester"),
                        Equipment(name: "Manual Harvester", imageName: "manual_harvester"),
                        Equipment(name: "Self-Propelled Harvester", imageName: "self_propelled_tobacco_harvester"),
                        Equipment(name: "Combine Harvester", imageName: "combine_tobacco_harvester")
                    ]
                ),
                EquipmentCategory(
                    title: "Planter",
                    equipmentList: [
                        Equipment(name: "Tobacco Planter", imageName: "tobacco_planter"),
                        Equipment(name: "Air Seed Planter", imageName: "air_seed_planter"),
                        Equipment(name: "Precision Planter", imageName: "precision_planter"),
                        Equipment(name: "Drill Planter", imageName: "drill_planter")
                    ]
                ),
                EquipmentCategory(
                    title: "Sprayer",
                    equipmentList: [
                        Equipment(name: "Boom Sprayer", imageName: "boom_sprayer"),
                        Equipment(name: "Handheld Sprayer", imageName: "handheld_sprayer"),
                        Equipment(name: "Field Sprayer", imageName: "field_sprayer"),
                        Equipment(name: "Aerial Sprayer", imageName: "aerial_sprayer")
                    ]
                )
            ]
        ),
        
        // Sugarcane
        CropCategory(
            cropName: "Sugarcane",
            EquipmentsForCrops: "Equipments For Sugarcane",
            equipments: [
                EquipmentCategory(
                    title: "Planter",
                    equipmentList: [
                        Equipment(name: "Sugarcane Planter", imageName: "sugarcane_planter"),
                        Equipment(name: "Row Sugarcane Planter", imageName: "row_sugarcane_planter"),
                        Equipment(name: "Automatic Sugarcane Planter", imageName: "automatic_sugarcane_planter"),
                        Equipment(name: "Manual Sugarcane Planter", imageName: "manual_sugarcane_planter")
                    ]
                ),
                EquipmentCategory(
                    title: "Harvester",
                    equipmentList: [
                        Equipment(name: "Sugarcane Harvester", imageName: "sugarcane_harvester"),
                        Equipment(name: "Chopper Harvester", imageName: "chopper_harvester"),
                        Equipment(name: "Self-Propelled Harvester", imageName: "self_propelled_sugarcane_harvester"),
                        Equipment(name: "Manual Harvester", imageName: "manual_sugarcane_harvester")
                    ]
                ),
                EquipmentCategory(
                    title: "Cultivator",
                    equipmentList: [
                        Equipment(name: "Sugarcane Cultivator", imageName: "sugarcane_cultivator"),
                        Equipment(name: "Tractor-Mounted Cultivator", imageName: "tractor_cultivator"),
                        Equipment(name: "Handheld Cultivator", imageName: "handheld_sugarcane_cultivator"),
                        Equipment(name: "Rotary Cultivator", imageName: "rotary_sugarcane_cultivator")
                    ]
                ),
                EquipmentCategory(
                    title: "Sprayer",
                    equipmentList: [
                        Equipment(name: "Boom Sprayer", imageName: "boom_sprayer"),
                        Equipment(name: "Backpack Sprayer", imageName: "backpack_sprayer"),
                        Equipment(name: "Field Sprayer", imageName: "field_sprayer"),
                        Equipment(name: "Aerial Sprayer", imageName: "aerial_sprayer")
                    ]
                )
            ]
        )
        
    ]
    
}



