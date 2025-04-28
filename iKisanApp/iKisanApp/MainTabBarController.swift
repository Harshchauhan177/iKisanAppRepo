//
//  MainTabBarController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 07/02/25.
//

import UIKit

class MainTabBarController: UITabBarController {

    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure dataController is initialized
        guard dataController != nil else {
            print("Error: DataController not initialized in MainTabBarController")
            // Show error alert
            let alert = UIAlertController(
                title: "Error",
                message: "Unable to initialize app data. Please try again later.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        setupTabs()
        setupNotificationObservers()
    }
    
    private func setupTabs() {
        // Home Tab
        let homeVC = HomeViewController()
        homeVC.dataController = dataController
        let homeNav = UINavigationController(rootViewController: homeVC)
        homeNav.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
        
        // Add other tabs as needed (AgriAssist, Coequip, etc.)
        // ...
        
        // Set view controllers (add your other tabs in the array as needed)
        self.viewControllers = [homeNav]
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
        
        // If we have a prebooking tab as the second tab, update it
        if viewControllers?.count ?? 0 > 1,
           let navController = viewControllers?[1] as? UINavigationController,
           let prebookingVC = navController.viewControllers.first as? PrebookingViewController {
            // Force refresh prebookings data
            prebookingVC.loadPreBookings()
        }
    }
    
    deinit {
        // Remove notification observers
        NotificationCenter.default.removeObserver(self)
    }
}
