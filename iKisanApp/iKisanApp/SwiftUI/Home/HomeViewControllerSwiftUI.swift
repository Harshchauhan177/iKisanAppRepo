//
//  HomeViewControllerSwiftUI.swift
//  iKisanApp
//
//  UIKit wrapper for SwiftUI HomeView
//

import UIKit
import SwiftUI

class HomeViewControllerSwiftUI: UIViewController {
    
    // DataController passed from MainTabBarController
    var dataController: DataController!
    
    private var hostingController: UIHostingController<HomeView>?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("🎉🎉🎉 HomeViewControllerSwiftUI INIT CALLED - SwiftUI version is being used! 🎉🎉🎉")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("🎉🎉🎉 HomeViewControllerSwiftUI INIT (coder) CALLED - SwiftUI version is being used! 🎉🎉🎉")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔥🔥🔥 HomeViewControllerSwiftUI viewDidLoad CALLED 🔥🔥🔥")
        
        // Ensure dataController is initialized
        guard dataController != nil else {
            print("❌ Error: DataController not initialized in HomeViewControllerSwiftUI")
            // Don't show alert - MainTabBarController handles initialization
            // This shouldn't happen if MainTabBarController is properly set up
            return
        }
        
        // Create SwiftUI view
        let homeView = HomeView()
        
        // Create hosting controller
        let hosting = UIHostingController(rootView: homeView)
        hostingController = hosting
        
        // Add as child view controller
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.frame = view.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.didMove(toParent: self)
        
        // Remove navigation bar from this view controller since SwiftUI handles it
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        print("✅ SwiftUI HomeView initialized successfully")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Keep navigation bar hidden
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restore navigation bar when leaving this view
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    deinit {
        print("🗑️ HomeViewControllerSwiftUI deinitialized")
    }
}
