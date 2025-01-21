//
//  CreateRequestViewController.swift
//  iKisanApp
//
//  Created by chandan kumar on 21/01/25.
//

import UIKit

class CreateRequestViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var categories = ["Crop","Pest","Disease","Fertilizer","Pesticide","Irrigation","Soil","Water","Other"]
    var card:[CardData]=[]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryCollectionView.delegate=self
        categoryCollectionView.dataSource=self
        cardCollectionView.delegate=self
        cardCollectionView.dataSource=self
        
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        cardCollectionView.register(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        
        card=[CardData(title: "Rice Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Raj Pal", imageName: "rice_harvester"),CardData(title: "Rice Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Raj Pal", imageName: "rice_harvester"),CardData(title: "Rice Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Raj Pal", imageName: "rice_harvester"),CardData(title: "Rice Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Raj Pal", imageName: "rice_harvester")]
    }
    

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == categoryCollectionView{
            return categories.count
        }else{
            return card.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView==categoryCollectionView{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
            cell.titleLabel.text = categories[indexPath.row]
            cell.titleLabel.textAlignment = .center
            cell.layer.cornerRadius=10
            cell.layer.borderWidth=1
            cell.layer.borderColor=UIColor.lightGray.cgColor
            return cell
            
        }else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
            let card = card[indexPath.row]
            cell.TitleLabel.text = card.title
            cell.PriceLabel.text = "\(card.price)₽"
            cell.ImageView.image = UIImage(named: card.imageName)
            cell.hostLabel.text = card.host
            cell.OrigianlPriceLabel.text = "\(String(describing: card.oldPrice))₽"
            cell.ratingLabel.text = "\(card.rating)"
            return cell
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView==categoryCollectionView{
            return CGSize(width: 100, height: 40)
        }else{
            return CGSize(width: 255, height: 259)
        }
    }

}
