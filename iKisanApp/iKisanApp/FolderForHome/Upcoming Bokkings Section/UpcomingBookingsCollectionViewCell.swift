//
//  UpcomingBookingsCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 22/01/25.
//

import UIKit

protocol UpcomingBookingsCollectionViewCellDelegate: AnyObject {
    func didTapViewButton(on cell: UpcomingBookingsCollectionViewCell)
}

class UpcomingBookingsCollectionViewCell: UICollectionViewCell {

    
    @IBOutlet var equipmentNameLabel: UILabel!
    
    
    @IBOutlet var bookingDateLabel: UILabel!
    
    @IBOutlet var hostedByLabel: UILabel!
    
    @IBOutlet var bookingStatusLabel: UILabel!
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var coEquipedOrNotLabel: UILabel!
    
    weak var delegate: UpcomingBookingsCollectionViewCellDelegate?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateUpcomingBookingsData(with indexPath: IndexPath) {
        imageView.image = UIImage(named: "4.jpeg")//UIImage(named: EquipmentData.equipment[indexPath.row].equipmentImage)
        imageView.layer.cornerRadius = 7
        equipmentNameLabel.text = "Rice Equipment"//EquipmentData.equipment[indexPath.row].name
        bookingDateLabel.text = "Wed, 25 Dec Afternoon"
        bookingStatusLabel.text = "Confirmed"
        coEquipedOrNotLabel.text = ""
        bookingStatusLabel.textColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        
        

    }
    
    
    @IBAction func viewButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
        
//        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
//        let viewController = storyboard.instantiateViewController(withIdentifier: " BookingDetailsViewController") as!
//        BookingDetailsViewController
//        //viewController.sectionNumber = sender.tag
//       navigationController?.pushViewController(viewController, animated: true)
   
    }
    
}
