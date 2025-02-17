//
//  InfoAboutEquipmentSection1CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 21/01/25.
//

import UIKit
import WebKit //
class InfoAboutEquipmentDetailsCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var equipmentTypeNameLabel: UILabel!
    @IBOutlet weak var equipmentTypeImageView: UIImageView!
    @IBOutlet weak var equipmentTypeLikedByLabel: UILabel!
    @IBOutlet weak var equipmentTypePurposeLabel: UILabel!
    @IBOutlet weak var equipmentTypeBestForLabel: UILabel!
    @IBOutlet weak var equipmentTypeAverageCostLabel: UILabel!
    @IBOutlet weak var equipmentTypeNeedsLabel: UILabel!
    
    private var webView: WKWebView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        equipmentTypeImageView.isUserInteractionEnabled = true
        // Add tap gesture recognizer to the image view
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        equipmentTypeImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func imageTapped() {
        // Play YouTube video when image is tapped
        if let parentViewController = self.parentViewController {
            // Initialize and configure WKWebView
            webView = WKWebView(frame: parentViewController.view.bounds)
            parentViewController.view.addSubview(webView)
            // Provide the YouTube video URL
            let videoURL = "https://youtu.be/s6vK-T7JQHk" // Replace with your YouTube video link
            if let url = URL(string: videoURL) {
                let request = URLRequest(url: url)
                webView.load(request)
            }
        }
    }
}

//extension UIView {
//    var parentViewController: UIViewController? {
//        var responder: UIResponder? = self
//        while responder != nil {
//            if let viewController = responder as? UIViewController {
//                return viewController
//            }
//            responder = responder?.next
//        }
//        return nil
//    }
//}

extension InfoAboutEquipmentDetailsCollectionViewCell {
    func configure(with equipment: EquipmentAgri) {
        print("Configuring section 1 cell with equipment: \(equipment.name)")
        
        equipmentTypeNameLabel.text = equipment.name
        equipmentTypeLikedByLabel.text = "\(equipment.likedBy)"
        
        if let image = UIImage(named: equipment.imageName) {
            equipmentTypeImageView.image = image
        } else {
            print("Warning: Image not found for \(equipment.imageName)")
            equipmentTypeImageView.image = UIImage(named: "placeholder_image")
        }
        
        equipmentTypePurposeLabel.text = equipment.purpose ?? "N/A"
        equipmentTypeBestForLabel.text = equipment.bestFor ?? "N/A"
        equipmentTypeAverageCostLabel.text = equipment.averageCost ?? "N/A"
        equipmentTypeNeedsLabel.text = equipment.needs ?? "N/A"
    }
}
