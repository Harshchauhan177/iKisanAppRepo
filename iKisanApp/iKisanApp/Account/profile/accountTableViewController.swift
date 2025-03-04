//
//  accountTableViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 03/03/25.
//

import UIKit

class accountTableViewController: UITableViewController {
    @IBOutlet weak var singOutcell: UITableViewCell!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    
    
    @IBOutlet weak var selectCropsCell: UITableViewCell!
    
    private let userDefaults = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadSavedData()
        
        // Add observer for profile updates
        NotificationCenter.default.addObserver(self,
                                             selector: #selector(profileUpdated),
                                             name: NSNotification.Name("UserProfileUpdated"),
                                             object: nil)
    }
    
    private func setupUI() {
        imageView.layer.cornerRadius = imageView.frame.width / 2
        imageView.clipsToBounds = true
    }
    
    private func loadSavedData() {
        nameLabel.text = userDefaults.string(forKey: "userName") ?? "Harsh Kumar"
        
        if let imageData = userDefaults.data(forKey: "userProfileImage"),
           let savedImage = UIImage(data: imageData) {
            imageView.image = savedImage
        }
    }
    
    @objc private func profileUpdated() {
        loadSavedData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let singOutCellIndexPath = tableView.indexPath(for: singOutcell), indexPath == singOutCellIndexPath {
            showSignOutAlert()
        }
        if let selectCropCellIndexPath = tableView.indexPath(for: selectCropsCell), indexPath == selectCropCellIndexPath {
            selectCropViewController()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }

    private func showSignOutAlert() {
        let alert = UIAlertController(title: "Sign Out Account", message: "Are you sure you want to sign Out your account?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler:nil))
        present(alert, animated: true, completion: nil)
    }

    private func selectCropViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "selectSessionCropsViewController") as? selectSessionCropsViewController{
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }

}
