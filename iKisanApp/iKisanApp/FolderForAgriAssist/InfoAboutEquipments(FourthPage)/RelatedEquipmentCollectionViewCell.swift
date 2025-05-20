//
//  InfoAboutEquipmentSection2CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 21/01/25.
//

import UIKit

class RelatedEquipmentCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var equipmentNameLabel: UILabel!
    @IBOutlet weak var equipmentImageView: UIImageView!
    @IBOutlet weak var equipmentLikedByLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    
    @IBAction func BookNowButton(_ sender: Any) {
        DispatchQueue.main.async {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController else {
                print("Error: Could not access tab bar controller")
                return
            }
            // Switch to Home tab (index 0)
            tabBarController.selectedIndex = 0
            // Dismiss any modals and pop to root
            windowScene.windows.first?.rootViewController?.dismiss(animated: true) {
                if let navController = tabBarController.selectedViewController as? UINavigationController,
                   let homeVC = navController.viewControllers.first as? HomeViewController {
                    navController.popToRootViewController(animated: false)
                    // Set the search bar text to the equipment name and trigger search
                    if let equipmentName = self.equipmentNameLabel?.text {
                        if let searchController = homeVC.navigationItem.searchController {
                            searchController.isActive = true
                            searchController.searchBar.text = equipmentName
                            homeVC.updateSearchResults(for: searchController)
                        }
                    }
                }
            }
        }
    }
    
    
    
    func configure(with equipment: EquipmentAgri) {
        print("Configuring section 2 cell with equipment: \(equipment.name)")
        
        equipmentNameLabel?.text = equipment.name
        
        // Check if the imageName is a URL or a local asset name
        if equipment.imageName.hasPrefix("http") {
            // It's a URL, use our ImageCache utility to load it
            equipmentImageView?.loadImage(from: equipment.imageName)
        } else {
            // Fallback to local asset loading for backward compatibility
            if let image = UIImage(named: equipment.imageName) {
                equipmentImageView?.image = image
            } else {
                print("Warning: Image not found for \(equipment.imageName)")
                equipmentImageView?.image = UIImage(named: "placeholder_image")
            }
        }
        
        
        
        
        
        // Configure other labels as needed
      //  equipmentPurposeLabel?.text = equipment.purpose ?? "N/A"
        equipmentLikedByLabel?.text = "\(equipment.likedBy)"
    }
}
