//
//  EquipmentDetailHostingController.swift
//  iKisanApp
//
//  UIKit wrapper for SwiftUI EquipmentDetailView
//

import UIKit
import SwiftUI

class EquipmentDetailHostingController: UIViewController {
    
    // MARK: - Properties
    
    var equipment: Equipment!
    var bookingSource: BookingSource!
    var dataController: DataController?
    weak var navigationCoordinator: HomeNavigationCoordinator?
    
    private var hostingController: UIHostingController<EquipmentDetailView>?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🎉 EquipmentDetailHostingController - Loading SwiftUI detail view")
        
        guard equipment != nil, bookingSource != nil else {
            print("❌ Error: Equipment or bookingSource not set")
            return
        }
        
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Hide navigation bar (SwiftUI view has custom back button)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Restore navigation bar when leaving
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    // MARK: - Setup
    
    private func setupSwiftUIView() {
        // Create ViewModel
        let viewModel = EquipmentDetailViewModel(
            equipment: equipment,
            bookingSource: bookingSource,
            dataController: dataController,
            navigationCoordinator: navigationCoordinator
        )
        
        // Create SwiftUI view
        let detailView = EquipmentDetailView(viewModel: viewModel)
        
        // Create hosting controller
        let hosting = UIHostingController(rootView: detailView)
        hostingController = hosting
        
        // Add as child view controller
        addChild(hosting)
        view.addSubview(hosting.view)
        
        // Setup constraints
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        hosting.didMove(toParent: self)
    }
}
