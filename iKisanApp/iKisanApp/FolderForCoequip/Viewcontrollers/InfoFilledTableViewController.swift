//
//  InfoFilledTableViewController.swift
//  iKisanApp
//
//  Created by chandan kumar on 21/01/25.
//

import UIKit

class InfoFilledTableViewController: UIViewController ,UITableViewDataSource, UITableViewDelegate{
    
    
    
    
    @IBOutlet weak var InformationFilled: UITableView!
    
    
    var rows: [InfoRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rows = [
            InfoRow(icon: UIImage(named: "locationIcon"), title: "Location", inputText: "New York", workingIcon: nil),
            InfoRow(icon: UIImage(named: "dateIcon"), title: "Date", inputText: "2025-01-21", workingIcon: nil),
            InfoRow(icon: UIImage(named: "areaIcon"), title: "Area", inputText: nil, workingIcon: nil),  // Area is editable
            InfoRow(icon: UIImage(named: "peopleIcon"), title: "Farmers", inputText: "5", workingIcon: nil)
        ]
        
        // Reload the table view to display the data
        InformationFilled.reloadData()
        
        // Reload the table view with data
        InformationFilled.register(UINib(nibName: "MYTableViewCell", bundle: nil), forCellReuseIdentifier: "cellforInfo")
    }
    
    
    
    // MARK: - Table View Data Source
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count  // Return the number of rows from the data source
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MYTableViewCell", for: indexPath) as! MYTableViewCell
        
        // Get the row data for the current index
        let row = rows[indexPath.row]
        
        // Configure the cell with the data
        cell.configure(with: row)
        
        return cell
    }
    
}
        

