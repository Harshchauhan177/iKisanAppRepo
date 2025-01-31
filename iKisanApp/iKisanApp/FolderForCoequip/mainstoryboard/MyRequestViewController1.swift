

import UIKit

class MyRequestViewController1: UIViewController {

    var request: Request?
    
    @IBOutlet weak var firstViewLabel: UIView!
    
    
    @IBOutlet weak var equipmentImageLabel: UIImageView!
    
    @IBOutlet weak var equipmentTitleLabel: UILabel!
    
    @IBOutlet weak var priceLabel: UILabel!
    
    @IBOutlet weak var hostNameLabel: UILabel!
    
    @IBOutlet weak var viewButtonLabel: UIButton!
    
    
    @IBOutlet weak var secondViewLabel: UIView!
    
    @IBOutlet weak var MinimumAreaLabel: UILabel!
    
    @IBOutlet weak var currentAreaLabel: UILabel!
    
    
    @IBOutlet weak var ListTableView: UITableView!
    
    @IBOutlet weak var modifyRequestLabel: UIButton!
    
    
    @IBOutlet weak var deleteRequestLabel: UIButton!
    
    
    var acceptedRequestPeopleList = [MyRequestInfo]()
    var person1 = MyRequestInfo(name: "Ravi", image: "101")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        acceptedRequestPeopleList.append(person1)
        ListTableView.delegate = self
        ListTableView.dataSource = self
        firstViewLabel.layer.cornerRadius = 7
        secondViewLabel.layer.cornerRadius = 7
        equipmentImageLabel.layer.cornerRadius = 7
        modifyRequestLabel.layer.cornerRadius = 7
        deleteRequestLabel.layer.cornerRadius = 7
        
    }
    

    
    @IBAction func ModifyButtonTapped(_ sender: Any) {
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Request", message: "Are you sure you want to delete this request?", preferredStyle: .alert)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                
                let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
                    // Call the delegate or pass the deleted request back
                    self?.deleteRequest()
                }
                alertController.addAction(deleteAction)
                self.present(alertController, animated: true, completion: nil)
    }
    private func deleteRequest() {
            if let requestToDelete = request {
              if let navigationController = self.navigationController,
                   let coequipVC = navigationController.viewControllers.first as? CoequipViewController {
                   if let index = coequipVC.requests.firstIndex(where: { $0.id == requestToDelete.id }) {
                        coequipVC.requests.remove(at: index)
                        coequipVC.CoequipTableView.reloadData()
                    }
                }
                navigationController?.popViewController(animated: true)
            }
        }
}
extension MyRequestViewController1: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acceptedRequestPeopleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)as! MyRequestInfoTableViewCell

        cell.nameLabel.text = acceptedRequestPeopleList[indexPath.row].name
        return cell
    }
    
    
}
