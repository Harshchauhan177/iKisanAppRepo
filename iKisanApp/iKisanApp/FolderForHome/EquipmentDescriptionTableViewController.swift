//
//  EquipmentDescriptionTableViewController.swift
//  iKisanApp
//
//  Created by ANSHU NAGAR on 18/01/25.
//

import UIKit

class EquipmentDescriptionTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    
    
    

    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        collectionView.delegate = self
               collectionView.dataSource = self
               
               // Configure collection view layout
               if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {

                   layout.minimumLineSpacing = 20
                   layout.scrollDirection = .horizontal
                   layout.minimumInteritemSpacing = 0
                   layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                   collectionView.isPagingEnabled = true
               }
    }

  
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! ReviewCardCollectionViewCell
                // Configure the card cell (e.g., set text, images, etc.)
        //cell.updateReviewCardData(reviewData: ReviewData[indexPath.row])
        cell.feedbackHeadingLabel.text = "Feedback"
        cell.feedbackTextLabel.text = "Rented the Square Baler for my wheat field—excellent performance, fuel-efficient, and easy to use. The rental process was hassle-free."
        
        cell.layer.cornerRadius = 7
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width /*- 32*/ // Account for left and right insets
               let height = collectionView.frame.height /*- 16*/ // Account for top and bottom insets
               return CGSize(width: width, height: height)
        }

}
