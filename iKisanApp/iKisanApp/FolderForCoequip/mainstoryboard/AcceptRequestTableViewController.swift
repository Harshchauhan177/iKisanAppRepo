

import UIKit

class AcceptRequestTableViewController: UITableViewController {
    var request: Request?
    
    @IBOutlet weak var imageLabel: UIImageView!
    
    @IBOutlet weak var TitleLabel: UILabel!
    
    @IBOutlet weak var viewLabel: UIButton!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!
    
    
    @IBOutlet weak var LocationLabel: UILabel!
    
    @IBOutlet weak var DateLabel: UILabel!
    
    @IBOutlet weak var IntputArea: UITextField!
    
    @IBOutlet weak var TimeSlotLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
    }

    
    @IBAction func AcceptButtonTapped(_ sender: Any) {
    }
    
    @IBAction func viewButtonTapped(_ sender: Any) {
    }
}
