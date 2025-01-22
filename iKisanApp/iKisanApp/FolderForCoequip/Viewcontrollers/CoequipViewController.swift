

import UIKit

class CoequipViewController: UIViewController,UITableViewDataSource, UITableViewDelegate  {
    
    
    
    var isMyRequestsSelected = true

    @IBOutlet weak var coequipsegmentedcontrol: UISegmentedControl!
    @IBOutlet weak var coequipTableCell: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        coequipTableCell.dataSource = self
        coequipTableCell.delegate = self
        coequipsegmentedcontrol.selectedSegmentIndex = 0
                coequipsegmentedcontrol.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        coequipTableCell.register(CoequipTableViewCell.self, forCellReuseIdentifier: "CoequipCell")



       
    }
    @objc func segmentChanged() {
            if coequipsegmentedcontrol.selectedSegmentIndex == 0 {
                isMyRequestsSelected = true
            } else {
                isMyRequestsSelected = false
            }
            coequipTableCell.reloadData()
        }
            

    @IBAction func plusButtonTapped(_ sender: UIBarButtonItem) {
        let searchVC = storyboard?.instantiateViewController(withIdentifier: "searchInCoequip") as! SearchViewController
            searchVC.modalPresentationStyle = .fullScreen
            present(searchVC, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CoequipCell", for: indexPath) as? CoequipTableViewCell {
            if isMyRequestsSelected {
                cell.confirmButton?.isHidden = true  // Hide second button
                cell.pendingButton?.setTitle("Pending", for: .normal)
            } else {
                cell.confirmButton?.isHidden = false  // Show second button
                cell.pendingButton?.setTitle("Pending", for: .normal)
                cell.confirmButton?.setTitle("Confirm", for: .normal)
            }
            return cell
        } else {
            fatalError("Failed to dequeue CoequipCell.")
        }

    }


}
