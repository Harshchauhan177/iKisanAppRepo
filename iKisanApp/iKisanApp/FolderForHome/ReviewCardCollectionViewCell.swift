//
//  ReviewCardCollectionViewCell.swift
//  iKisanApp
//
//  Created by ANSHU NAGAR on 17/01/25.
//

import UIKit

class ReviewCardCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet var feedbackHeadingLabel: UILabel!
    
    @IBOutlet var star1Image: UIImageView!
    @IBOutlet var star2Image: UIImageView!
    @IBOutlet var star3Image: UIImageView!
    @IBOutlet var star4Image: UIImageView!
    @IBOutlet var star5Image: UIImageView!
    
    @IBOutlet var feedbackTextLabel: UILabel!
    
    
    func updateReviewCardData(reviewData: ReviewData) {
        feedbackHeadingLabel.text = reviewData.reviewHeading
        feedbackTextLabel.text = reviewData.reviewDescription
        
        switch reviewData.rating {
        case 1:
            star1Image.image = UIImage(named: "star_filled")
            star2Image.image = UIImage(named: "star_empty")
            star3Image.image = UIImage(named: "star_empty")
            star4Image.image = UIImage(named: "star_empty")
            star5Image.image = UIImage(named: "star_empty")
            
        case 2:
            star1Image.image = UIImage(named: "star_filled")
            star2Image.image = UIImage(named: "star_filled")
            star3Image.image = UIImage(named: "star_empty")
            star4Image.image = UIImage(named: "star_empty")
            star5Image.image = UIImage(named: "star_empty")
            
            case 3:
            star1Image.image = UIImage(named: "star_filled")
            star2Image.image = UIImage(named: "star_filled")
            star3Image.image = UIImage(named: "star_filled")
            star4Image.image = UIImage(named: "star_empty")
            star5Image.image = UIImage(named: "star_empty")
            
            case 4:
            star1Image.image = UIImage(named: "star_filled")
            star2Image.image = UIImage(named: "star_filled")
            star3Image.image = UIImage(named: "star_filled")
            star4Image.image = UIImage(named: "star_filled")
            star5Image.image = UIImage(named: "star_empty")
            
            case 5:
            star1Image.image = UIImage(named: "star_filled")
            star2Image.image = UIImage(named: "star_filled")
            star3Image.image = UIImage(named: "star_filled")
            star4Image.image = UIImage(named: "star_filled")
            star5Image.image = UIImage(named: "star_filled")
            
        default:
            star1Image.image = UIImage(named: "star_empty")
            star2Image.image = UIImage(named: "star_empty")
            star3Image.image = UIImage(named: "star_empty")
            star4Image.image = UIImage(named: "star_empty")
            star5Image.image = UIImage(named: "star_empty")
            
        }
    }
    
    
}
