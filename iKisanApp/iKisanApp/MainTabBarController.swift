//
//  MainTabBarController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 07/02/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    // Making dataController public to allow access from child view controllers
    public var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🚀 MainTabBarController viewDidLoad called")
        
        // Always setup view controllers first (SwiftUI replacement happens here)
        setupViewControllers()
        setupNotificationObservers()
        
        // Check dataController after setup (log warning but don't block)
        if dataController == nil {
            print("⚠️ Warning: DataController not initialized in MainTabBarController")
            // Note: App continues to work, dataController may be set later
        } else {
            print("✅ DataController is initialized")
        }
    }
    
    private func setupViewControllers() {
        print("📋 setupViewControllers() called")
        
        // The tabs are already set up in the storyboard
        // We just need to pass the dataController to each view controller
        
        guard let viewControllers = self.viewControllers else {
            print("❌ Error: No view controllers found in MainTabBarController")
            return
        }
        
        print("📱 Found \(viewControllers.count) view controllers to process")
        
        // Iterate through all tab bar view controllers and assign dataController
        for (index, viewController) in viewControllers.enumerated() {
            print("🔍 Processing view controller at index \(index): \(type(of: viewController))")
            
            if let navController = viewController as? UINavigationController {
                print("  ✓ Is UINavigationController with \(navController.viewControllers.count) child(ren)")
                
                if let firstVC = navController.viewControllers.first {
                    print("  ➡️ First child type: \(type(of: firstVC))")
                }
                
                // ✅ SWIFTUI ENABLED: Replace UIKit HomeViewController with SwiftUI version
                if navController.viewControllers.first is HomeViewController {
                    print("🔄 FOUND HomeViewController at index \(index) - REPLACING WITH SWIFTUI VERSION")
                    let swiftUIHomeVC = HomeViewControllerSwiftUI()
                    swiftUIHomeVC.dataController = dataController
                    navController.setViewControllers([swiftUIHomeVC], animated: false)
                    print("✅ Successfully replaced with HomeViewControllerSwiftUI")
                    continue
                }
                
                // ✅ SWIFTUI ENABLED: Replace UIKit CoequipViewController with SwiftUI version
                if navController.viewControllers.first is CoequipViewController {
                    print("🔄 FOUND CoequipViewController at index \(index) - REPLACING WITH SWIFTUI VERSION")
                    let swiftUICoEquipVC = CoEquipHostingController(dataController: dataController)
                    navController.setViewControllers([swiftUICoEquipVC], animated: false)
                    print("✅ Successfully replaced with CoEquipHostingController (SwiftUI)")
                    continue
                }
                // ✅ END SWIFTUI
                
                // Keep other tabs as UIKit for now
                if let homeVC = navController.viewControllers.first as? HomeViewController {
                    print("Setting up HomeViewController at index \(index)")
                    homeVC.dataController = dataController
                } else if let prebookingVC = navController.viewControllers.first as? PrebookingViewController {
                    print("Setting up PrebookingViewController at index \(index)")
                    prebookingVC.dataController = dataController
                } else if let agriAssistVC = navController.viewControllers.first as? AgriAssistViewController {
                    print("Setting up AgriAssistViewController at index \(index)")
                    agriAssistVC.dataController = dataController
                } else if let coequipVC = navController.viewControllers.first as? CoequipViewController {
                    print("Setting up CoequipViewController at index \(index)")
                    coequipVC.dataController = dataController
                }
            }
        }
    }
    
    private func setupNotificationObservers() {
        // Register for booking notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookingAdded(_:)),
            name: .bookingAdded,
            object: nil
        )
        
        // Register for prebooking notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePreBookingAdded(_:)),
            name: Notification.Name.preBookingAdded,
            object: nil
        )
    }
    
    @objc private func handleBookingAdded(_ notification: Notification) {
        print("MainTabBarController - Received bookingAdded notification")
        
        // Ensure the home tab is updated (first tab)
        if let navController = viewControllers?[0] as? UINavigationController,
           let homeVC = navController.viewControllers.first as? HomeViewController {
            // Force refresh data on the home view controller
            homeVC.loadData()
        }
    }
    
    @objc private func handlePreBookingAdded(_ notification: Notification) {
        print("MainTabBarController - Received preBookingAdded notification")
        
        // Find the index of the Prebooking tab
        var prebookingTabIndex: Int? = nil
        
        if let viewControllers = self.viewControllers {
            for (index, viewController) in viewControllers.enumerated() {
                if let navController = viewController as? UINavigationController,
                   navController.viewControllers.first is PrebookingViewController {
                    prebookingTabIndex = index
                    break
                }
            }
        }
        
        // If we found the prebooking tab, switch to it and refresh it
        if let index = prebookingTabIndex,
           let navController = viewControllers?[index] as? UINavigationController,
           let prebookingVC = navController.viewControllers.first as? PrebookingViewController {
            // Force refresh prebookings data
            prebookingVC.loadPreBookings()
            
            // Switch to the prebooking tab
            self.selectedIndex = index
            print("Switching to Prebooking tab at index \(index)")
        } else {
            print("Error: Could not find Prebooking tab")
        }
    }
    
    deinit {
        // Remove notification observers
        NotificationCenter.default.removeObserver(self)
    }
}
