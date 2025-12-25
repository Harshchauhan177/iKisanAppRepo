//
//  CoEquipHostingController.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 25/12/25.
//

import UIKit
import SwiftUI

/// UIKit hosting controller for the SwiftUI Co-Equip view
/// This allows seamless integration with the existing UIKit-based tab bar
class CoEquipHostingController: UIHostingController<CoEquipView> {
    
    /// DataController passed from MainTabBarController
    var dataController: DataController?
    
    init(dataController: DataController? = nil) {
        // Create view model with data controller
        let viewModel = CoEquipViewModel(dataController: dataController)
        super.init(rootView: CoEquipView(viewModel: viewModel))
        
        self.dataController = dataController
        setupAppearance()
    }
    
    @MainActor required dynamic init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder, rootView: CoEquipView(viewModel: CoEquipViewModel()))
        setupAppearance()
    }
    
    private func setupAppearance() {
        // Match the tab bar item from the UIKit version
        self.tabBarItem = UITabBarItem(
            title: "Co-Equip",
            image: UIImage(systemName: "person.2"),
            selectedImage: UIImage(systemName: "person.2.fill")
        )
        
        // Ensure proper navigation bar appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.compactAppearance = appearance
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Hide the default navigation bar if using SwiftUI NavigationStack
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
