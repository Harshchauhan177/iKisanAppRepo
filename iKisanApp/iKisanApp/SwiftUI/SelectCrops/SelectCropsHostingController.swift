//
//  SelectCropsHostingController.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 16/12/25.
//

import SwiftUI
import UIKit

/// UIKit hosting controller for the SwiftUI SelectCropsView
/// Bridges UIKit navigation to SwiftUI content
final class SelectCropsHostingController: UIHostingController<SelectCropsView> {
    
    // MARK: - Properties
    
    private let isFromProfile: Bool
    
    // MARK: - Initialization
    
    init(dataController: DataController = IKisanDataController(), isFromProfile: Bool = false) {
        self.isFromProfile = isFromProfile
        
        let selectCropsView = SelectCropsView(
            dataController: dataController,
            isFromProfile: isFromProfile
        )
        
        super.init(rootView: selectCropsView)
        
        setupNotificationObservers()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure navigation bar
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        // Add back button if from profile
        if isFromProfile {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: "chevron.left"),
                style: .plain,
                target: self,
                action: #selector(backButtonTapped)
            )
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCropSelectionCompleted),
            name: .cropSelectionCompleted,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCropSelectionCompletedOnboarding),
            name: .cropSelectionCompletedOnboarding,
            object: nil
        )
    }
    
    @objc private func backButtonTapped() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func handleCropSelectionCompleted() {
        // Return to profile
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc private func handleCropSelectionCompletedOnboarding() {
        // Transition to main interface after onboarding
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.switchToMainInterfaceAfterLogin()
        }
    }
}
