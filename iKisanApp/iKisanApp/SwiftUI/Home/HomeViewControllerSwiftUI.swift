//
//  HomeViewControllerSwiftUI.swift
//  iKisanApp
//
//  UIKit wrapper for SwiftUI HomeView with Navigation Bridge
//

import UIKit
import SwiftUI

class HomeViewControllerSwiftUI: UIViewController {
    
    // MARK: - Properties
    
    /// DataController passed from MainTabBarController
    var dataController: DataController!
    
    /// Navigation coordinator that bridges SwiftUI to UIKit navigation
    private var navigationCoordinator: UIKitHomeNavigationCoordinator?
    
    /// Hosting controller for SwiftUI view
    private var hostingController: UIHostingController<HomeView>?
    
    /// ViewModel instance for dependency injection
    private var viewModel: HomeViewModel?
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("🎉 HomeViewControllerSwiftUI INIT - SwiftUI version is being used!")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("🎉 HomeViewControllerSwiftUI INIT (coder) - SwiftUI version is being used!")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔥 HomeViewControllerSwiftUI viewDidLoad")
        
        // Ensure dataController is initialized
        guard dataController != nil else {
            print("❌ Error: DataController not initialized in HomeViewControllerSwiftUI")
            return
        }
        
        setupSwiftUIView()
        setupNotificationObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Keep navigation bar hidden (SwiftUI handles its own navigation bar)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Refresh data when view appears
        refreshData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Restore navigation bar when leaving this view
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup Methods
    
    private func setupSwiftUIView() {
        // Create navigation coordinator
        navigationCoordinator = UIKitHomeNavigationCoordinator(
            navigationController: self.navigationController,
            dataController: dataController
        )
        
        // Create ViewModel and inject dependencies
        let viewModel = HomeViewModel()
        viewModel.navigationCoordinator = navigationCoordinator
        viewModel.dataController = dataController
        self.viewModel = viewModel
        
        // Create SwiftUI view with injected ViewModel
        let homeView = HomeView(viewModel: viewModel)
        
        // Create hosting controller
        let hosting = UIHostingController(rootView: homeView)
        hostingController = hosting
        
        // Add as child view controller
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.frame = view.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.didMove(toParent: self)
        
        print("✅ SwiftUI HomeView initialized with navigation bridge")
    }
    
    private func setupNotificationObservers() {
        // Listen for booking notifications to refresh the view
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookingNotification(_:)),
            name: .bookingAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBookingNotification(_:)),
            name: .preBookingAdded,
            object: nil
        )
    }
    
    // MARK: - Data Management
    
    private func refreshData() {
        // Refresh data in the SwiftUI ViewModel when view appears
        if let viewModel = self.viewModel {
            Task {
                await viewModel.refreshData()
            }
        }
    }
    
    @objc private func handleBookingNotification(_ notification: Notification) {
        print("🔔 HomeViewControllerSwiftUI - Received booking notification")
        refreshData()
    }
    
    // MARK: - Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("🗑️ HomeViewControllerSwiftUI deinitialized")
    }
}
