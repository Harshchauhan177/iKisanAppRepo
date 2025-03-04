import UIKit


class InfoTableViewController: UITableViewController,UITextFieldDelegate{
    
    
    @IBOutlet weak var ImageLabel: UIImageView!
    @IBOutlet weak var TitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hostName: UILabel!
    @IBOutlet weak var InputAreaLabel: UITextField!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var TimeSlotLabel: UILabel!
    @IBOutlet weak var FarmerListLabel: UILabel!
    
    
    var location: String = "Some Location"
    var timeSlot: String = "08:00"
    var date: Date? = Date()
    var cardData: Equipment?
    let startTime = 8 * 60
    var selectedUsers: [User] = []
    var isModifying = false
    var existingRequest: Request?
    var dataController: DataController?
    private var currentTimeSlot: TimeSlot = .morning
    private var timeSlots: [String] = []
    var updateCompletionHandler: ((Request) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ImageLabel.layer.cornerRadius = 7
        InputAreaLabel.delegate = self
        if let data = cardData {
            setupUI(with: data)
        }
        if isModifying, let request = existingRequest {
            InputAreaLabel.text = String(request.area)
            TimeSlotLabel.text = request.timePeriod
            currentTimeSlot = request.timeSlot
            updateFarmerList()
            navigationItem.rightBarButtonItem?.title = "Update"
        }
        InputAreaLabel.addTarget(self, action: #selector(areaInputChanged(_:)), for: .editingChanged)
        updateFarmerList()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateFarmerList()
    }
    
    @IBAction func viewButtomTapped(_ sender: Any) {
    }
    
    
    @IBAction func AddFarmerButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: "goToList", sender: sender)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, let area = Double(text) {
            calculateTimeSlot(for: area)
        }
        textField.resignFirstResponder()
        return true
    }

    private func calculateTimeSlot(for area: Double) {
        let timeRequired = area * 0.5
        timeSlots.removeAll()
        var currentTime = startTime
        while currentTime < (17 * 60) {
            let endTime = min(currentTime + Int(timeRequired * 60), 17 * 60)
            let timeSlotString = formatTimeSlot(start: currentTime, end: endTime)
            timeSlots.append(timeSlotString)
            currentTime += 30
        }
        if let firstSlot = timeSlots.first {
            self.timeSlot = firstSlot
            TimeSlotLabel.text = firstSlot
            let hour = currentTime / 60
            if hour < 12 {
                currentTimeSlot = .morning
            } else if hour < 15 {
                currentTimeSlot = .afternoon
            } else {
                currentTimeSlot = .evening
            }
        }
    }

    private func formatTimeSlot(start: Int, end: Int) -> String {
        let startHour = start / 60
        let startMinute = start % 60
        let endHour = end / 60
        let endMinute = end % 60
        
        return String(format: "%02d:%02d - %02d:%02d", startHour, startMinute, endHour, endMinute)
    }

    
    @IBAction func unwindToInfoTableViewController(segue: UIStoryboardSegue) {
        if let sourceVC = segue.source as? SelectPeopleViewController {
            selectedUsers = sourceVC.selectedUsers
            updateFarmerList()
        }
    }
    
    func updateFarmerList() {
        if selectedUsers.isEmpty {
            FarmerListLabel.text = "No farmers selected"
            FarmerListLabel.textColor = .gray
        } else {
            let farmerNames = selectedUsers.map { user in
                return user.name
            }
            let farmersText = farmerNames.joined(separator: ", ")
            FarmerListLabel.text = farmersText
            FarmerListLabel.textColor = .black
        }
    }
    
    func clearSelectedFarmers() {
        selectedUsers.removeAll()
        updateFarmerList()
    }
    
    @IBAction func CreateButtonTapped(_ sender: Any) {
        guard let dataController = self.dataController else {
            showAlert(message: "System error: Data controller not found")
            return
        }
        guard let equipment = cardData,
              let selectedDate = date,
              let areaText = InputAreaLabel.text,
              !areaText.isEmpty,
              let area = Double(areaText) else {
            showAlert(message: "Please fill in all required fields")
            return
        }
        if isModifying {
            guard let existingRequest = existingRequest else {
                showAlert(message: "Error: Original request not found")
                return
            }
            let updatedRequest = Request(
                id: existingRequest.id,
                userId: existingRequest.userId,
                equipmentId: equipment.equipmentID,
                requestedDate: selectedDate,
                status: existingRequest.status,
                type: existingRequest.type,
                area: area,
                timeSlot: currentTimeSlot,
                timePeriod: timeSlot,
                location: location, typeOfRequest: .myRequest,
                selectedUsers: selectedUsers,
                joinedFarmers: selectedUsers.map { $0.userID }
            )
            dataController.updateRequest(updatedRequest)
            updateCompletionHandler?(updatedRequest)
            let successAlert = UIAlertController(
                title: "Success",
                message: "Request updated successfully",
                preferredStyle: .alert
            )
            
            successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                self?.navigationController?.popViewController(animated: true)
            })
            
            present(successAlert, animated: true)
            
        } else {
            let newRequest = Request(
                userId: currentUser.shared.user?.userID ?? UUID(),
                equipmentId: equipment.equipmentID,
                requestedDate: selectedDate,
                status: .pending,
                type: .coEquip,
                area: area,
                timeSlot: currentTimeSlot,
                timePeriod: timeSlot,
                location: location,
                typeOfRequest: .myRequest, selectedUsers: selectedUsers,
                joinedFarmers: selectedUsers.map { $0.userID }
            )
            dataController.addNewCoEquipRequest(newRequest)
            let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
            if let coequipVC = storyboard.instantiateViewController(withIdentifier: "CoequipViewController") as? CoequipViewController {
                coequipVC.dataController = dataController
                coequipVC.currentRequest = newRequest
                showSuccessAndNavigateBack()
            }
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCoequip",
           let destinationVC = segue.destination as? CoequipViewController,
           let request = sender as? Request {
            destinationVC.currentRequest = request // Pass the request to CoequipViewController
        }
    }
    
    private func calculateTimePeriod(for area: Double) -> String {
        let durationInMinutes = Int(area * 30)
        let startTime = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
        let endTime = startTime.addingTimeInterval(Double(durationInMinutes * 60))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return "\(dateFormatter.string(from: startTime)) - \(dateFormatter.string(from: endTime))"
    }
    
    private func showSuccessAndNavigateBack() {
        let successAlert = UIAlertController(
            title: "Success",
            message: "Your co-equip request has been created successfully.",
            preferredStyle: .alert
        )
        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            self?.navigateToCoequip()
        })
        present(successAlert, animated: true)
    }
    
    private func navigateToCoequip() {
        if let navigationController = self.navigationController {
            if let coequipVC = navigationController.viewControllers.first(where: { $0 is CoequipViewController }) {
                navigationController.popToViewController(coequipVC, animated: true)
            } else {
                navigationController.popToRootViewController(animated: true)
            }
        }
    }
    private func setupUI(with data: Equipment) {
        TitleLabel.text = data.name
        priceLabel.text = "₹ \(data.pricePerHour)"
        hostName.text = "Ram Pal"//data.providerID.uuidString
        ImageLabel.image = UIImage(named: data.equipmentImage)

        if let currentDate = date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            dateLabel.text = dateFormatter.string(from: currentDate)
        }
    }
    @objc func areaInputChanged(_ textField: UITextField) {
        if let text = textField.text, let area = Double(text) {
            calculateTimeSlot(for: area)
        }
    }
    func configure(with equipment: Equipment, dataController: DataController, date: Date = Date()) {
        self.cardData = equipment
        self.dataController = dataController
        self.date = date
        if isViewLoaded {
            setupUI(with: equipment)
            updateFarmerList()
        }
    }
}

