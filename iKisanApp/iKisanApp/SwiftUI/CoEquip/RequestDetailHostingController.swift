//
//  RequestDetailHostingController.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 26/12/25.
//

import UIKit
import SwiftUI

/// UIKit hosting controller for the SwiftUI Request Detail view
/// Allows seamless integration with existing UIKit navigation
class RequestDetailHostingController: UIHostingController<RequestDetailView>, CoEquipNavigationCoordinator {
    
    // MARK: - Properties
    
    private let viewModel: RequestDetailViewModel
    var dataController: DataController?
    
    // MARK: - Initialization
    
    init(request: Request, dataController: DataController?) {
        self.dataController = dataController
        self.viewModel = RequestDetailViewModel(
            request: request,
            dataController: dataController,
            coordinator: nil
        )
        
        super.init(rootView: RequestDetailView(viewModel: viewModel))
        
        // Set self as coordinator after initialization
        self.viewModel.setCoordinator(self)
        
        setupAppearance()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupAppearance() {
        // Ensure proper navigation bar appearance
        navigationItem.largeTitleDisplayMode = .never
    }
    
    // MARK: - CoEquipNavigationCoordinator
    
    func navigateToAcceptRequest(request: Request, equipment: Equipment) {
        // Navigate to AcceptRequestTableViewController (existing UIKit view)
        let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
        
        if let acceptRequestVC = storyboard.instantiateViewController(withIdentifier: "AcceptRequestTableViewController") as? AcceptRequestTableViewController {
            acceptRequestVC.request = request
            acceptRequestVC.dataController = dataController
            navigationController?.pushViewController(acceptRequestVC, animated: true)
        }
    }
    
    func navigateToModifyRequest(request: Request, equipment: Equipment) {
        // Navigate to InfoTableViewController for modification
        let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
        
        if let infoVC = storyboard.instantiateViewController(withIdentifier: "InfoTableViewController") as? InfoTableViewController {
            infoVC.isModifying = true
            infoVC.existingRequest = request
            infoVC.cardData = equipment
            infoVC.dataController = dataController
            navigationController?.pushViewController(infoVC, animated: true)
        }
    }
    
    func navigateToEquipmentDetail(equipment: Equipment) {
        // Fallback to UIKit equipment detail
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        
        if let equipmentDetailVC = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
            equipmentDetailVC.equipment = equipment
            equipmentDetailVC.bookingSource = .coEquipViewOnly
            navigationController?.pushViewController(equipmentDetailVC, animated: true)
        }
    }
    
    func dismissRequestDetail() {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Helper Methods
    
    private func findHomeNavigationCoordinator() -> HomeNavigationCoordinator? {
        // Try to find a HomeNavigationCoordinator in the navigation stack
        // This allows reusing the SwiftUI equipment detail view if available
        guard let navController = navigationController else { return nil }
        
        for viewController in navController.viewControllers {
            if let hostingController = viewController as? UIHostingController<AnyView> {
                // Check if this hosting controller has a coordinator
                // This is a simplified check - in production you'd have a more robust way
                return nil
            }
        }
        
        return nil
    }
}
