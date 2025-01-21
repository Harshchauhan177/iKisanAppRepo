//
//  ListViewController.swift
//  iKisanApp
//
//  Created by chandan kumar on 22/01/25.
//

import UIKit

class ListViewController: UIViewController {

    @IBOutlet weak var SelectFarmerList: UITableView!
    
    
    var selectedRows: Set<IndexPath> = []

        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Register the nib file for the custom cell
            let nib = UINib(nibName: "ListTableViewCell", bundle: nil) // "ListTableViewCell" is the name of your nib file
            SelectFarmerList.register(nib, forCellReuseIdentifier: "ListTableViewCell") // This matches the reuse identifier
            
            SelectFarmerList.delegate = self
            SelectFarmerList.dataSource = self
        }

        @IBAction func DoneButtonTapped(_ sender: Any) {
            // Process the selected items here
            var selectedItems: [Int] = []
            
            // Collect the selected row indices
            for indexPath in selectedRows {
                selectedItems.append(indexPath.row)
            }
            
            print("Selected items: \(selectedItems)")
        }
    }

    extension ListViewController: UITableViewDataSource, UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return 10 // Number of rows in your table
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // Dequeue the custom cell using the registered reuse identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableViewCell", for: indexPath) as! ListTableViewCell
            
            // Configure the cell
            cell.textLabel?.text = "Row \(indexPath.row)"
            
            // Set the checkmark if this row is selected
            if selectedRows.contains(indexPath) {
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
            
            return cell
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Add to selected rows
            selectedRows.insert(indexPath)
            // Update the accessory type to show the checkmark
            tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        }
        
        func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
            // Remove from selected rows
            selectedRows.remove(indexPath)
            // Update the accessory type to remove the checkmark
            tableView.cellForRow(at: indexPath)?.accessoryType = .none
        }
    }
