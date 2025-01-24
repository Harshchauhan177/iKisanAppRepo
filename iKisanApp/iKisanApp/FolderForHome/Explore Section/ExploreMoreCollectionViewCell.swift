//
//  ExploreMoreCollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 2 on 15/01/25.
//

import UIKit

protocol ExploreMoreCollectionViewCellDelegate: AnyObject {
    func didTapViewButton(on cell: ExploreMoreCollectionViewCell)
}

class ExploreMoreCollectionViewCell: UICollectionViewCell {
    
    var faderView: UIView? = nil
    
    @IBOutlet var exploreEquipmentImageView: UIImageView!
    
    @IBOutlet var equipmentNameLabel: UILabel!
    @IBOutlet var discountedPriceLabel: UILabel!
    @IBOutlet var realPriceLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var providerNameLabel: UILabel!
    
    weak var delegate: ExploreMoreCollectionViewCellDelegate?
    func updateExploreMoreData(with indexPath: IndexPath) {
        
        exploreEquipmentImageView.image = UIImage(named: EquipmentData.equipment[indexPath.row].equipmentImage)
        equipmentNameLabel.text = EquipmentData.equipment[indexPath.row].name
        discountedPriceLabel.text = "\(EquipmentData.equipment[indexPath.row].pricePerHour)"
        realPriceLabel.text = "\(EquipmentData.equipment[indexPath.row].pricePerHour)"
        ratingLabel.text = "\(EquipmentData.equipment[indexPath.row].rating)"
//        // Adjust fader view transparency based on image color
//        if let image = exploreEquipmentImageView.image {
//            let brightness = calculateBrightness(of: image)
//            faderView = setupFaderOverlay()
//            adjustFaderViewTransparency(brightness: brightness, faderView: faderView)
//        }
        
    }
    
    
//    private func calculateBrightness(of image: UIImage) -> CGFloat {
//            // Create a CGImage from the UIImage
//            guard let cgImage = image.cgImage else { return 0 }
//            
//            // Get pixel data from the image
//            let width = cgImage.width
//            let height = cgImage.height
//            let bytesPerPixel = 4
//            let bytesPerRow = bytesPerPixel * width
//            let pixelData = cgImage.dataProvider?.data
//            
//            guard let data = CFDataGetBytePtr(pixelData) else { return 0 }
//
//            var totalBrightness: CGFloat = 0
//            
//            for y in 0..<height {
//                for x in 0..<width {
//                    let pixelIndex = (y * bytesPerRow) + (x * bytesPerPixel)
//                    let red = CGFloat(data[pixelIndex]) / 255.0
//                    let green = CGFloat(data[pixelIndex + 1]) / 255.0
//                    let blue = CGFloat(data[pixelIndex + 2]) / 255.0
//                    
//                    // Calculate the brightness of the pixel (luminosity formula)
//                    let brightness = 0.299 * red + 0.587 * green + 0.114 * blue
//                    totalBrightness += brightness
//                }
//               
//            }
//        print("brightness :\(totalBrightness)")
//            let averageBrightness = totalBrightness / CGFloat(width * height)
//            return averageBrightness
//        }
//    
//    private func adjustFaderViewTransparency(brightness: CGFloat, faderView: UIView?) {
//            guard let faderView = faderView else { return }
//
//            // Darker images will have a higher alpha to enhance visibility of text
//            let alpha: CGFloat = brightness < 0.5 ? 0.7 : 0.3 // Higher alpha for darker images
//
//            // Adjust the fader's color and transparency
//            faderView.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.0, alpha: alpha)
//        print("faderView background\(faderView.alpha)")
//        }
//    
//    override func awakeFromNib() {
//           super.awakeFromNib()
////        faderView = setupFaderOverlay()
//       }
//
//    private func setupFaderOverlay() -> UIView {
//           // Create a green fader overlay
//           let faderView = UIView(frame: .zero)
////           faderView.backgroundColor = UIColor(red: 0.0, green: 0.3, blue: 0.0, alpha: 0.3) // Exact green color with semi-transparency
//           faderView.translatesAutoresizingMaskIntoConstraints = false
//           contentView.addSubview(faderView)
//
//           // Constrain the fader to the bottom portion of the image
//           NSLayoutConstraint.activate([
//               faderView.leadingAnchor.constraint(equalTo: exploreEquipmentImageView.leadingAnchor),
//               faderView.trailingAnchor.constraint(equalTo: exploreEquipmentImageView.trailingAnchor),
//               faderView.bottomAnchor.constraint(equalTo: exploreEquipmentImageView.bottomAnchor),
//               faderView.heightAnchor.constraint(equalTo: exploreEquipmentImageView.heightAnchor, multiplier: 0.35) // Height set to bottom 35%
//           ])
//
//           // Ensure the button and label stay on top
//           contentView.bringSubviewToFront(equipmentNameLabel)
//           contentView.bringSubviewToFront(discountedPriceLabel)
//           contentView.bringSubviewToFront(realPriceLabel)
//           contentView.bringSubviewToFront(ratingLabel)
//           contentView.bringSubviewToFront(providerNameLabel)
//
//           contentView.bringSubviewToFront(bookNowButtonTapped)
//        print("Inside overlay")
//        return faderView
//       }
//    
   
    @IBAction func bookNowButtonTapped(_ sender: Any) {
        delegate?.didTapViewButton(on: self)
    }
    
    
}
