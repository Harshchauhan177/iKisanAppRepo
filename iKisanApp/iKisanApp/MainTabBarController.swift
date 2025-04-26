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
}
