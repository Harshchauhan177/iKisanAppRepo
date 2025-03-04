//
//  SettingTableViewController.swift
//  iKisanApp
//
//  Created by harsh chauhan on 04/03/25.
//

import UIKit

class SettingTableViewController: UITableViewController {

    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    @IBOutlet weak var deleteAccountCell: UITableViewCell!
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            if indexPath.row == tableView.indexPath(for: deleteAccountCell)?.row {
                let alert = UIAlertController(title: "Delete Account",
                                              message: "Are you sure you want to delete your account?",
                                              preferredStyle: .alert)
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.deleteAccount()
                }))
                
                present(alert, animated: true, completion: nil)
            }
        }

        private func deleteAccount() {
            print("Account deleted")
        }
}
