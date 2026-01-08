//
//  SelectEquipmentHostingController.swift
//  iKisanApp
//
//  UIKit wrapper for SwiftUI SelectEquipmentView
//  Enables seamless integration with existing UIKit navigation flow
//

import UIKit
import SwiftUI

/// UIKit hosting controller for SelectEquipmentView
class SelectEquipmentHostingController: UIViewController {
    
    // MARK: - Properties
    
    var dataController: DataController!
    var selectedDate: Date?
    var initialSearchSuggestion: String?
    
    private var hostingController: UIHostingController<NavigationStack<NavigationPath, SelectEquipmentView>>?
    
    // Completion handler for equipment selection (deprecated - navigation handled internally)
    var onEquipmentSelected: ((Equipment, Date) -> Void)?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("🎉 SelectEquipmentHostingController - Loading SwiftUI select equipment view")
        
        guard dataController != nil else {
            print("❌ Error: DataController not set")
            showErrorAndDismiss()
            return
        }
        
        setupSwiftUIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Keep navigation bar visible for SwiftUI navigation to work
        // The SwiftUI view will manage its own navigation bar appearance
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Navigation bar state managed by navigation controller
    }
    
    // MARK: - Setup
    
    private func setupSwiftUIView() {
        // Create ViewModel
        let viewModel = SelectEquipmentViewModel(
            dataController: dataController,
            initialSearchSuggestion: initialSearchSuggestion
        )
        
        // Set initial selected date if provided
        if let date = selectedDate {
            viewModel.selectedDate = date
        }
        
        // Create SwiftUI View wrapped in NavigationStack for internal navigation
        let swiftUIView = NavigationStack {
            SelectEquipmentView(viewModel: viewModel)
        }
        
        // Create Hosting Controller
        let hosting = UIHostingController(rootView: swiftUIView)
        hostingController = hosting
        
        // Add as child view controller
        addChild(hosting)
        view.addSubview(hosting.view)
        hosting.didMove(toParent: self)
        
        // Setup constraints
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        print("✅ SelectEquipmentView embedded successfully")
    }
    
    // MARK: - Equipment Selection
    
    // MARK: - Error Handling
    
    private func showErrorAndDismiss() {
        let alert = UIAlertController(
            title: "Error",
            message: "System error: Please try again later",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        })
        present(alert, animated: true)
    }
}

// MARK: - Factory Method

extension SelectEquipmentHostingController {
    
    /// Factory method to create a configured instance
    static func create(
        dataController: DataController,
        selectedDate: Date? = nil,
        initialSearchSuggestion: String? = nil,
        onEquipmentSelected: ((Equipment, Date) -> Void)? = nil
    ) -> SelectEquipmentHostingController {
        let controller = SelectEquipmentHostingController()
        controller.dataController = dataController
        controller.selectedDate = selectedDate
        controller.initialSearchSuggestion = initialSearchSuggestion
        controller.onEquipmentSelected = onEquipmentSelected
        return controller
    }
}
