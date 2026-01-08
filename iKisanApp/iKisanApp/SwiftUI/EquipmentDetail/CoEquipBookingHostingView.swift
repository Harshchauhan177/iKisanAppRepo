//
//  CoEquipBookingHostingView.swift
//  iKisanApp
//
//  SwiftUI wrapper for CoEquip booking UIKit flow
//

import SwiftUI
import UIKit

/// SwiftUI wrapper that hosts the UIKit InfoTableViewController for Co-Equip booking
struct CoEquipBookingHostingView: UIViewControllerRepresentable {
    
    let equipment: Equipment
    let dataController: DataController?
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
        
        if let viewController = storyboard.instantiateViewController(withIdentifier: "InfoTableViewController") as? InfoTableViewController {
            // Pass the equipment data
            viewController.cardData = equipment
            
            // Set the data controller if needed
            if let dataController = dataController {
                viewController.dataController = dataController
            }
            
            print("✅ Created InfoTableViewController for Co-Equip booking")
            
            // Wrap in navigation controller for proper navigation flow
            let navController = UINavigationController(rootViewController: viewController)
            return navController
        } else {
            print("❌ Failed to instantiate InfoTableViewController")
            // Return empty navigation controller as fallback
            return UINavigationController()
        }
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        // No updates needed
    }
}
