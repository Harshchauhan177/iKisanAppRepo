//
//  UpcomingBookingsListCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 22/01/25.
//

import UIKit

class UpcomingBookingsListCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!
    
    @IBOutlet var equipmentNameLabel: UILabel!
    @IBOutlet var bookingDateLabel: UILabel!
    @IBOutlet var hostedByLabel: UILabel!
    @IBOutlet var coEquippedStatusLabel: UILabel!
    @IBOutlet var bokkingStatusLabel: UILabel!
    
    
    func updateCellData(with indexPath:IndexPath) {
        equipmentNameLabel.text = "hello"
        imageView.layer.cornerRadius = 7
    }
    
    override init(frame : CGRect){
        super.init(frame: frame)
        
        updateCellUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateCellUI()
    }
    
    func updateCellUI () {
        self.layer.cornerRadius = 5
        self.backgroundColor = .white
        
    
        //self.backgroundColor = .green.withAlphaComponent(0.4)
    }
    
    
    
    
    
    @IBAction func viewButtonTapped(_ sender: Any) {
    }
    
}
