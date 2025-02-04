//
//  reviewPreBookingTableViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 04/02/25.
//

import UIKit

class reviewPreBookingTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        

    }

    @IBAction func sendRequestButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "Request Sent", message: "Your request for Rice Harvester has been sent.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "View", style: .default, handler: { _ in
                print("View tapped")
                
//                if let prebookingVC = self.storyboard?.instantiateViewController(withIdentifier: "PrebookingViewController") as? PrebookingViewController {
//                            prebookingVC.targetSection = 3
//                            self.navigationController?.pushViewController(prebookingVC, animated: true)
//                        }
                
                
//                if let prebookingVC = self.navigationController?.viewControllers.first(where: { $0 is PrebookingViewController }) as? PrebookingViewController {
//                            prebookingVC.targetSection = 2 // Set target to section 2 (third section)
//                            self.navigationController?.popToViewController(prebookingVC, animated: true)
//                            
//                            // Assuming PrebookingViewController has a UICollectionView and it's accessible
//                            if let collectionView = prebookingVC.collectionView {
//                                let indexPath = IndexPath(item: 0, section: 3) // Section 2 (0-based index)
//                                collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
//                            }
//                        }
                
                if let prebookingVC = self.navigationController?.viewControllers.first(where: { $0 is PrebookingViewController }) as? PrebookingViewController {
                            prebookingVC.targetSection = 2 // Set target to section 2 (third section)
                            self.navigationController?.popToViewController(prebookingVC, animated: true)
                            
                            // Scroll to section header
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                                prebookingVC.scrollToSectionHeader(section: 3) // Scroll to section 2 header
                            }
                        }
                
            
            }))
            
            alert.addAction(UIAlertAction(title: "Done", style: .default, handler: { _ in
                print("Done tapped")
                
//                if let prebookingVC = self.navigationController?.viewControllers.first(where: { $0 is PrebookingViewController }) as? PrebookingViewController {
//                            prebookingVC.targetSection = 2 // Set target to section 2 (third section)
//                            self.navigationController?.popToViewController(prebookingVC, animated: true)
//                            
//                            // Assuming PrebookingViewController has a UICollectionView and it's accessible
//                            if let collectionView = prebookingVC.collectionView {
//                                let indexPath = IndexPath(item: 0, section: 0) // Section 2 (0-based index)
//                                collectionView.scrollToItem(at: indexPath, at: .top, animated: true)
//                            }
//                        }
                
                
                if let prebookingVC = self.navigationController?.viewControllers.first(where: { $0 is PrebookingViewController }) as? PrebookingViewController {
                            prebookingVC.targetSection = 2 // Set target to section 2 (third section)
                            self.navigationController?.popToViewController(prebookingVC, animated: true)
                            
                            // Scroll to section header
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                prebookingVC.scrollToSectionHeader(section: 0) // Scroll to section 2 header
                            }
                        }
                
                
                
            }))
            
            present(alert, animated: true, completion: nil)
        
    }
    

    

}
