//
//  PrebookingViewControllerSwiftUI.swift
//  iKisanApp
//
//  UIKit wrapper for SwiftUI PreBookingLandingView.
//  Follows the same pattern as HomeViewControllerSwiftUI.
//  Receives DataController from MainTabBarController and bridges navigation.
//

import UIKit
import SwiftUI

class PrebookingViewControllerSwiftUI: UIViewController {
    
    // MARK: - Properties
    
    /// DataController passed from MainTabBarController
    var dataController: DataController!
    
    /// Navigation coordinator that bridges SwiftUI to UIKit navigation
    private var navigationCoordinator: UIKitHomeNavigationCoordinator?
    
    /// Hosting controller for SwiftUI view
    private var hostingController: UIHostingController<PreBookingLandingView>?
    
    /// ViewModel instance for dependency injection
    private var viewModel: PreBookingLandingViewModel?
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("🎉 PrebookingViewControllerSwiftUI INIT - SwiftUI version is being used!")
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        print("🎉 PrebookingViewControllerSwiftUI INIT (coder) - SwiftUI version is being used!")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🔥 PrebookingViewControllerSwiftUI viewDidLoad")
        
        // Ensure dataController is initialized
        guard dataController != nil else {
            print("❌ Error: DataController not initialized in PrebookingViewControllerSwiftUI")
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
        let viewModel = PreBookingLandingViewModel(
            dataController: dataController,
            navigationCoordinator: navigationCoordinator
        )
        self.viewModel = viewModel
        
        // Create SwiftUI view with injected ViewModel
        let landingView = PreBookingLandingView(viewModel: viewModel)
        
        // Create hosting controller
        let hosting = UIHostingController(rootView: landingView)
        hostingController = hosting
        
        // Add as child view controller
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.view.frame = view.bounds
        hosting.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hosting.didMove(toParent: self)
        
        print("✅ SwiftUI PreBookingLandingView initialized with navigation bridge")
    }
    
    private func setupNotificationObservers() {
        // Listen for prebooking notifications to refresh the view
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePreBookingNotification(_:)),
            name: .preBookingAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleRefreshNotification(_:)),
            name: NSNotification.Name("RefreshBookingsList"),
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
    
    @objc private func handlePreBookingNotification(_ notification: Notification) {
        print("🔔 PrebookingViewControllerSwiftUI - Received preBookingAdded notification")
        viewModel?.handlePreBookingAdded()
    }
    
    @objc private func handleRefreshNotification(_ notification: Notification) {
        print("🔔 PrebookingViewControllerSwiftUI - Received RefreshBookingsList notification")
        refreshData()
    }
    
    // MARK: - Deinitialization
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        print("🗑️ PrebookingViewControllerSwiftUI deinitialized")
    }
}
