//
//  OnboardingHostingController.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 16/12/25.
//

import SwiftUI
import UIKit

/// UIKit hosting controller for the SwiftUI OnboardingView
/// Bridges UIKit navigation to SwiftUI content
final class OnboardingHostingController: UIHostingController<OnboardingView> {
    
    // MARK: - Initialization
    
    init() {
        super.init(rootView: OnboardingView())
        setupNotificationObservers()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide navigation bar for onboarding
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleOnboardingCompleted),
            name: .onboardingCompleted,
            object: nil
        )
    }
    
    @objc private func handleOnboardingCompleted() {
        // Transition to login screen
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.switchToMainInterface()
        }
    }
}
