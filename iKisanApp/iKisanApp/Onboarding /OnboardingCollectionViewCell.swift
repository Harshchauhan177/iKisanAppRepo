//
//  OnboardingCollectionViewCell.swift
//  LearnSathi
//
//  Created by Admin on 18/02/25.
//

import UIKit

class OnboardingCollectionViewCell: UICollectionViewCell {
    
//    static let identifier = String("OnboardingCollectionViewCell")
    static let identifier = String(describing: OnboardingCollectionViewCell.self)

    
    @IBOutlet weak var slideImageView: UIImageView!
    @IBOutlet weak var slideTitleLogo: UIImageView!
    @IBOutlet weak var slideTitleLbl: UILabel!
    @IBOutlet weak var slideDescriptionlbl: UILabel!
    
    func setup(_ slide: OnboardingSlide) {
        slideImageView.image = slide.image
        slideTitleLbl.text = slide.title
        slideDescriptionlbl.text = slide.description
        slideTitleLogo.image = slide.logo
    }
}
