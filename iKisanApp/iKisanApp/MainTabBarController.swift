//
//  MainTabBarController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 07/02/25.
//

import UIKit
import SwiftUI

class MainTabBarController: UITabBarController {

    // Making dataController public to allow access from child view controllers
    public var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        print("🚀 MainTabBarController viewDidLoad called")

        // Pre-warm GroupPaymentManager on main thread to ensure Razorpay SDK
        // initializes correctly (WebKit requires main thread for message handlers)
        GroupPaymentManager.preWarm()

        // Configure tab bar appearance for iOS 26 Liquid Glass / modern look
        configureTabBarAppearance()

        // On iOS 18+, use the modern UITab API for programmatic tab setup.
        // This replaces the storyboard-based tab configuration and enables
        // the iOS 26 Liquid Glass floating tab bar automatically.
        if #available(iOS 18.0, *) {
            configureModernTabs()
        } else {
            // Fallback: use the legacy storyboard-based setup for older iOS
            setupViewControllers()
        }
        
        setupNotificationObservers()
        
        // Check dataController after setup (log warning but don't block)
        if dataController == nil {
            print("⚠️ Warning: DataController not initialized in MainTabBarController")
            // Note: App continues to work, dataController may be set later
        } else {
            print("✅ DataController is initialized")
        }
    }
    
    // MARK: - Tab Bar Appearance (iOS 26 Liquid Glass)
    
    /// Configures the tab bar appearance to enable the system's default material
    /// (Liquid Glass on iOS 26). Removes any hardcoded background/tint overrides
    /// that were previously set in the storyboard, which would block the system
    /// from rendering the translucent glass effect.
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
        
        // Clear the storyboard's hardcoded backgroundColor on the tabBar itself.
        // The storyboard sets tabBar.backgroundColor = .white directly, which
        // overrides the appearance-based configuration and blocks the system's
        // Liquid Glass material from rendering on iOS 26.
        tabBar.backgroundColor = nil
        tabBar.isTranslucent = true
        
        // Preserve the iKisan green tint for selected tab items
        tabBar.tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
        
        print("✅ Tab bar appearance configured for modern iOS styling")
    }
    
    // MARK: - Modern Tab Configuration (iOS 18+ UITab API)
    
    /// Sets up tabs using the modern UITab API introduced in iOS 18.
    /// This programmatic approach replaces the storyboard-based tab definitions
    /// and is required for the iOS 26 Liquid Glass tab bar to render correctly.
    /// Each tab wraps its SwiftUI view controller inside a UINavigationController,
    /// preserving the same navigation hierarchy as the storyboard-based setup.
    @available(iOS 18.0, *)
    private func configureModernTabs() {
        print("📋 configureModernTabs() called — using UITab API")
        
        // Tab 1: iKisan (Home)
        let homeTab = UITab(
            title: "iKisan",
            image: UIImage(systemName: "house"),
            identifier: "home"
        ) { [weak self] _ in
            let navController = UINavigationController()
            let swiftUIHomeVC = HomeViewControllerSwiftUI()
            swiftUIHomeVC.dataController = self?.dataController
            navController.setViewControllers([swiftUIHomeVC], animated: false)
            print("✅ UITab: Home tab created with HomeViewControllerSwiftUI")
            return navController
        }
        
        // Tab 2: Pre Booking
        let prebookingTab = UITab(
            title: "Pre Booking",
            image: UIImage(systemName: "book"),
            identifier: "prebooking"
        ) { [weak self] _ in
            let navController = UINavigationController()
            let swiftUIPrebookingVC = PrebookingViewControllerSwiftUI()
            swiftUIPrebookingVC.dataController = self?.dataController
            navController.setViewControllers([swiftUIPrebookingVC], animated: false)
            print("✅ UITab: Pre Booking tab created with PrebookingViewControllerSwiftUI")
            return navController
        }
        
        // Tab 3: CoEquip
        let coequipTab = UITab(
            title: "CoEquip",
            image: UIImage(systemName: "person.3"),
            identifier: "coequip"
        ) { [weak self] _ in
            let navController = UINavigationController()
            let swiftUICoEquipVC = CoEquipHostingController(dataController: self?.dataController)
            navController.setViewControllers([swiftUICoEquipVC], animated: false)
            print("✅ UITab: CoEquip tab created with CoEquipHostingController")
            return navController
        }
        
        // Tab 4: AgriAssist
        let agriAssistTab = UITab(
            title: "AgriAssist",
            image: UIImage(systemName: "lightbulb.max"),
            identifier: "agriassist"
        ) { _ in
            let navController = UINavigationController()
            let swiftUIView = NavigationStack {
                AgriAssistView()
            }
            let hostingController = UIHostingController(rootView: swiftUIView)
            hostingController.navigationItem.hidesBackButton = true
            navController.setViewControllers([hostingController], animated: false)
            // Hide the UIKit navigation bar to avoid double titles
            navController.setNavigationBarHidden(true, animated: false)
            print("✅ UITab: AgriAssist tab created with SwiftUI AgriAssistView")
            return navController
        }
        
        self.tabs = [homeTab, prebookingTab, coequipTab, agriAssistTab]
        print("📱 Set \(self.tabs.count) tabs via UITab API")
    }
    
    // MARK: - Legacy Storyboard-Based Setup (< iOS 18)
    
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
                
                // ✅ SWIFTUI ENABLED: Replace UIKit PrebookingViewController with SwiftUI version
                if navController.viewControllers.first is PrebookingViewController {
                    print("🔄 FOUND PrebookingViewController at index \(index) - REPLACING WITH SWIFTUI VERSION")
                    let swiftUIPrebookingVC = PrebookingViewControllerSwiftUI()
                    swiftUIPrebookingVC.dataController = dataController
                    navController.setViewControllers([swiftUIPrebookingVC], animated: false)
                    print("✅ Successfully replaced with PrebookingViewControllerSwiftUI")
                    continue
                }
                // ✅ END SWIFTUI
                
                // ✅ SWIFTUI ENABLED: Replace UIKit AgriAssistViewController with SwiftUI version
                if navController.viewControllers.first is AgriAssistViewController {
                    print("🔄 FOUND AgriAssistViewController at index \(index) - REPLACING WITH SWIFTUI VERSION")
                    let swiftUIView = NavigationStack {
                        AgriAssistView()
                    }
                    let hostingController = UIHostingController(rootView: swiftUIView)
                    hostingController.navigationItem.hidesBackButton = true
                    navController.setViewControllers([hostingController], animated: false)
                    // Hide the UIKit navigation bar to avoid double titles
                    navController.setNavigationBarHidden(true, animated: false)
                    print("✅ Successfully replaced with SwiftUI AgriAssistView")
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
    
    // MARK: - Notification Observers
    
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
        // Works with both legacy viewControllers and modern UITab API —
        // viewControllers is still populated by UITabBarController in both paths.
        if let navController = viewControllers?[0] as? UINavigationController,
           let homeVC = navController.viewControllers.first as? HomeViewController {
            // Force refresh data on the home view controller
            homeVC.loadData()
        }
    }
    
    @objc private func handlePreBookingAdded(_ notification: Notification) {
        print("MainTabBarController - Received preBookingAdded notification")
        
        // Find the index of the Prebooking tab (supports both UIKit and SwiftUI versions)
        var prebookingTabIndex: Int? = nil
        
        if let viewControllers = self.viewControllers {
            for (index, viewController) in viewControllers.enumerated() {
                if let navController = viewController as? UINavigationController {
                    let firstVC = navController.viewControllers.first
                    if firstVC is PrebookingViewController || firstVC is PrebookingViewControllerSwiftUI {
                        prebookingTabIndex = index
                        break
                    }
                }
            }
        }
        
        // If we found the prebooking tab, switch to it and refresh it
        if let index = prebookingTabIndex,
           let navController = viewControllers?[index] as? UINavigationController {
            
            // Handle UIKit version
            if let prebookingVC = navController.viewControllers.first as? PrebookingViewController {
                prebookingVC.loadPreBookings()
            }
            // SwiftUI version handles refresh via NotificationCenter observer internally
            
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
