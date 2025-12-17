//
//  OnboardingSlideModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 16/12/25.
//

import SwiftUI

/// Represents a single onboarding slide with all necessary data
struct OnboardingSlideModel: Identifiable, Equatable {
    let id = UUID()
    let title: String
    let description: String
    let imageName: String
    let logoSystemName: String
    
    static func == (lhs: OnboardingSlideModel, rhs: OnboardingSlideModel) -> Bool {
        lhs.id == rhs.id
    }
}
