import UIKit

class MyRequestViewController1: UIViewController {

    var request: Request?
    var dataController: DataController?
    
    @IBOutlet weak var firstViewLabel: UIView!
    @IBOutlet weak var equipmentImageLabel: UIImageView!
    @IBOutlet weak var equipmentTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hostNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var viewButtonLabel: UIButton!
    @IBOutlet weak var secondViewLabel: UIView!
    @IBOutlet weak var minimumAreaLabel: UILabel!
    @IBOutlet weak var currentAreaLabel: UILabel!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var modifyRequestLabel: UIButton!
    @IBOutlet weak var deleteRequestLabel: UIButton!
    
    var acceptedRequestPeopleList: [User] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let request = request,
           let equipment = dataController?.getEquipmentById(request.equipmentId) {
            // Check if the equipmentImage is a URL or a local asset name
            if equipment.equipmentImage.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                equipmentImageLabel.loadImage(from: equipment.equipmentImage)
            } else {
                // Fallback to local asset loading for backward compatibility
                equipmentImageLabel.image = UIImage(named: equipment.equipmentImage) ?? UIImage(named: "placeholder_image")
            }
            equipmentTitleLabel.text = equipment.name
            hostNameLabel.text = "Ram Pal"//equipment.providerID.uuidString
            currentAreaLabel.text = "\(request.area) acres"
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            let dateString = dateFormatter.string(from: request.requestedDate)
            dateLabel.text = "\(dateString)"
            let totalPrice = equipment.pricePerAcre * request.area
            priceLabel.text = "₹ \(Int(totalPrice))\nDate: \(dateString)"
            listTableView.delegate = self
            listTableView.dataSource = self
            acceptedRequestPeopleList = request.selectedUsers
            listTableView.reloadData()
        }
        setupViewAppearance()
    }
    
    private func setupViewAppearance() {
        firstViewLabel.layer.cornerRadius = 7
        secondViewLabel.layer.cornerRadius = 7
        equipmentImageLabel.layer.cornerRadius = 7
        modifyRequestLabel.layer.cornerRadius = 7
        deleteRequestLabel.layer.cornerRadius = 7
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Request", 
                                              message: "Are you sure you want to delete this request?", 
                                              preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alertController.addAction(cancelAction)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteRequest()
        }
        alertController.addAction(deleteAction)
        present(alertController, animated: true)
    }
    
    private func deleteRequest() {
        if let requestToDelete = request,
           let dataController = dataController {
            dataController.deleteRequest(with: requestToDelete.id)
            if let navigationController = self.navigationController,
               let coequipVC = navigationController.viewControllers.first(where: { $0 is CoequipViewController }) as? CoequipViewController {
                coequipVC.loadInitialData()
            }
            let successAlert = UIAlertController(
                title: "Success", 
                message: "Request deleted successfully", 
                preferredStyle: .alert
            )
            successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            present(successAlert, animated: true)
        }
    }
    
    @IBAction func ModifyButtonTapped(_ sender: Any) {
        guard let request = request,
              let dataController = dataController else {
            showAlert(message: "Error: Request data not found")
            return
        }
        guard let equipment = dataController.getEquipmentById(request.equipmentId) else {
            showAlert(message: "Error: Equipment data not found")
            return
        }
        let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
        if let infoTableVC = storyboard.instantiateViewController(withIdentifier: "InfoTableViewController") as? InfoTableViewController {
            infoTableVC.isModifying = true
            infoTableVC.existingRequest = request
            infoTableVC.cardData = equipment
            infoTableVC.dataController = dataController
            infoTableVC.date = request.requestedDate
            infoTableVC.selectedUsers = request.selectedUsers
            infoTableVC.location = request.location
            infoTableVC.updateCompletionHandler = { [weak self] updatedRequest in
                self?.dataController?.updateRequest(updatedRequest)
                self?.request = updatedRequest
                self?.viewDidLoad()
            }
            navigationController?.pushViewController(infoTableVC, animated: true)
        }
    }
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Alert",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    func configure(with request: Request) {
        self.request = request
    }
}

extension MyRequestViewController1: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return acceptedRequestPeopleList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyRequestInfoTableViewCell
        let person = acceptedRequestPeopleList[indexPath.row]
        cell.nameLabel.text = person.name
        return cell
    }
}
