//
//  CropModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 16/12/25.
//

import Foundation

/// SwiftUI-compatible crop model with selection state
struct CropModel: Identifiable, Equatable {
    let id: UUID
    let name: String
    let imageURL: String
    var isSelected: Bool
    var fieldArea: String
    
    init(id: UUID, name: String, imageURL: String, isSelected: Bool = false, fieldArea: String = "") {
        self.id = id
        self.name = name
        self.imageURL = imageURL
        self.isSelected = isSelected
        self.fieldArea = fieldArea
    }
    
    /// Creates a CropModel from the existing Crop struct
    init(from crop: Crop, isSelected: Bool = false, fieldArea: String = "") {
        self.id = crop.id
        self.name = crop.name
        self.imageURL = crop.imageURL
        self.isSelected = isSelected
        self.fieldArea = fieldArea
    }
    
    static func == (lhs: CropModel, rhs: CropModel) -> Bool {
        lhs.id == rhs.id && 
        lhs.isSelected == rhs.isSelected && 
        lhs.fieldArea == rhs.fieldArea
    }
}
