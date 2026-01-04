//
//  CoEquipCreationView.swift
//  iKisanApp
//
//  Entry point for Co-Equip booking flow
//  Navigates to CreateCoEquipGroupView
//

import SwiftUI

/// Entry view for Co-Equip creation flow
/// This view immediately navigates to the CreateCoEquipGroupView
struct CoEquipCreationView: View {
    
    let equipment: Equipment
    weak var dataController: DataController?
    weak var navigationCoordinator: HomeNavigationCoordinator?
    
    @State private var navigateToCreateGroup = false
    
    var body: some View {
        // Automatically navigate to CreateCoEquipGroupView
        CreateCoEquipGroupView(
            viewModel: CreateCoEquipGroupViewModel(
                equipment: equipment,
                dataController: dataController,
                navigationCoordinator: navigationCoordinator
            )
        )
    }
}
