//
//  selectCropsTableViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 18/02/25.
//

import UIKit

class selectCropsTableViewCell: UITableViewCell {

    @IBOutlet weak var cropImageView: UIImageView!
    @IBOutlet weak var cropNameLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    private func setupUI() {
        // Add any custom UI setup here
        cropImageView.contentMode = .scaleAspectFit
        cropImageView.clipsToBounds = true
        
        // Optional: Add corner radius to image
        cropImageView.layer.cornerRadius = 8
        cropImageView.layer.masksToBounds = true
    }
    
    func configure(with crop: Crop) {
        cropNameLabel.text = crop.name
        // Use the existing ImageCache utility to load and cache the image
        if !crop.imageURL.isEmpty {
            cropImageView.loadImage(from: crop.imageURL, placeholder: UIImage(systemName: "leaf"))
        } else {
            cropImageView.image = UIImage(systemName: "leaf")
        }
    }
    

    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    
//    var isSelectedState: Bool = false
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        print("Cell awakeFromNib: \(self)")
//      
//      
//    }
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }
//
//
//    func UpdateCellData(with people: PersonList){
//        cropNameLabel.text = people.name
//        
//    }
//   
//    @IBAction func CheckBoxButtonTapped(_ sender: UIButton) {
//        isSelectedState.toggle()
//            sender.isSelected = isSelectedState
//    }
//    
//    override func setSelected(_ selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//    }
//    
    

}
