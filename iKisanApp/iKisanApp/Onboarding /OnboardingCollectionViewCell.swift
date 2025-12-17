//
//  OnboardingCollectionViewCell.swift
//  LearnSathi
//
//  Created by Admin on 18/02/25.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
    static let identifier = String(describing: OnboardingCollectionViewCell.self)
    
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var slideTitleLogo: UIImageView!
    @IBOutlet weak var slideTitleLbl: UILabel!
    @IBOutlet weak var slideDescriptionlbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDynamicType()
    }
    
    private func setupDynamicType() {
        // Enable Dynamic Type for labels
        slideTitleLbl?.adjustsFontForContentSizeCategory = true
        slideDescriptionlbl?.adjustsFontForContentSizeCategory = true
        slideDescriptionlbl?.numberOfLines = 0 // Allow multi-line wrapping
        
        // Set text colors that adapt to dark mode
        slideTitleLbl?.textColor = .label
        slideDescriptionlbl?.textColor = .label
    }
    
    func setup(_ slide: OnboardingSlide) {
        slideImageView.image = slide.image
        slideTitleLbl.text = slide.title
        slideDescriptionlbl.text = slide.description
        slideTitleLogo.image = slide.logo
        
        // Accessibility
        slideImageView.isAccessibilityElement = true
        slideImageView.accessibilityLabel = "\(slide.title) illustration"
        slideImageView.accessibilityTraits = .image
        
        slideTitleLogo.isAccessibilityElement = false // Decorative
        
        // Make the entire cell accessible with combined info
        isAccessibilityElement = false
        accessibilityElements = [slideTitleLbl as Any, slideDescriptionlbl as Any]
    }
}
