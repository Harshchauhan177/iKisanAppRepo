

import UIKit

class AcceptRequestTableViewController: UITableViewController {
    var request: Request?
    
    @IBOutlet weak var imageLabel: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var viewLabel: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var intputArea: UITextField!
    
    @IBOutlet weak var timeSlotLabel: UILabel!
    
    let validStartTime = "08:00"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageLabel.layer.cornerRadius = 7
        //IntputArea.addTarget(self, action: #selector(areaInputChanged), for: .editingChanged)
    }
    @objc func areaInputChanged() {
    
        if let areaText = intputArea.text, !areaText.isEmpty {
                    updateTimeSlot(basedOn: areaText)
                }
        }
    func updateTimeSlot(basedOn areaText: String) {
        let areaCount = areaText.split(separator: " ").count
                let durationInMinutes = areaCount * 30
                let startTime = validStartTime
                let endTime = getEndTime(from: startTime, durationInMinutes:durationInMinutes)
                timeSlotLabel.text = "\(startTime) - \(endTime)"
    }
    
    func getEndTime(from startTime: String,durationInMinutes: Int) -> String {
        let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                if let startDate = formatter.date(from: startTime) {
                    let endDate = startDate.addingTimeInterval(Double(durationInMinutes * 60))
                    return formatter.string(from: endDate)
                }
                return startTime
        }
    
    @IBAction func AcceptButtonTapped(_ sender: Any) {
        guard let title = titleLabel.text, !title.isEmpty,
                      let location = LocationLabel.text, !location.isEmpty,
                      let price = priceLabel.text, !price.isEmpty,
                      let host = hostLabel.text, !host.isEmpty,
                      let timeSlot = timeSlotLabel.text, !timeSlot.isEmpty,
                      let area = intputArea.text, !area.isEmpty else {
                          showAlert(title: "Missing Information", message: "Please fill in all the details before accepting the request.")
                          return
                }

        let areaCount = area.split(separator: " ").count
                let expectedEndTime = getEndTime(from: validStartTime, durationInMinutes: areaCount * 30)
                if timeSlot != "\(validStartTime) - \(expectedEndTime)" {
                    showAlert(title: "Invalid Time Slot", message: "Please Enter Area Correctly")
                    return
                }
                showAlert(title: "Success", message: "You have successfully accepted the request.")
    }
    
    
    
    
    @IBAction func viewButtonTapped(_ sender: Any) {
    }
    func showAlert(title: String, message: String) {
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(okAction)
            present(alertController, animated: true, completion: nil)
        }
}
