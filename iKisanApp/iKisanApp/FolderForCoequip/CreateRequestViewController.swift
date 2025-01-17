//
//  CreateRequestViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit

class CreateRequestViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    
    

    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    let categories = ["Combine", "Rice", "Corn", "Top-rated", "Premium"]
        let cards = [
            ("Rice Harvester", "₹1100/hr", "₹1250", "4.5", "Hosted by VeerPal"),
            ("Rice Harvester", "₹1000/hr", "₹1150", "4.0", "Hosted by RamPal"),
            ("Corn Harvester", "₹1200/hr", "₹1300", "4.8", "Hosted by Singh"),
            ("Premium Harvester", "₹1500/hr", "₹1750", "5.0", "Hosted by Rajesh")
        ]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "Create Request"

                // Configure date label
                dateLabel.text = "Select Date: January 17, 2025"
                dateLabel.textAlignment = .center

                // Set up collection views
                categoryCollectionView.delegate = self
                categoryCollectionView.dataSource = self
                cardCollectionView.delegate = self
                cardCollectionView.dataSource = self

                // Register custom cells
                categoryCollectionView.register(UINib(nibName: "CategoryCellOut", bundle: nil), forCellWithReuseIdentifier: "CategoryCellOut")
                cardCollectionView.register(UINib(nibName: "CardCellOut", bundle: nil), forCellWithReuseIdentifier: "CardCellOut")
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView {
                    return categories.count
                } else {
                    return cards.count
                }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
                    cell.configure(category: categories[indexPath.item])
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
                    let card = cards[indexPath.item]
                    cell.configure(title: card.0, price: card.1, originalPrice: card.2, rating: card.3, host: card.4)
                    return cell
                }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            if collectionView == categoryCollectionView {
                return CGSize(width: 100, height: 50) // Horizontal category cells
            } else {
                let height = (cardCollectionView.frame.height - 20) / 2 // Two cards per screen
                return CGSize(width: cardCollectionView.frame.width - 20, height: height)
            }
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return 10
        }
}
