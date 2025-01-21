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
    
    var categories = ["Combine","Rice","Wheat","soyabean","Irrigation","Other"]
    var card:[CardData]=[]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryCollectionView.delegate=self
        categoryCollectionView.dataSource=self
        cardCollectionView.delegate=self
        cardCollectionView.dataSource=self
        
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        cardCollectionView.register(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        
        card=[CardData(title: "Rice Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Raj Pal", imageName: UIImage(named: "101")!),CardData(title: "Rice Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Raj Pal", imageName: UIImage(named: "102")!),CardData(title: "Rice Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Raj Pal", imageName: UIImage(named: "103")!),CardData(title: "Rice Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Raj Pal", imageName: UIImage(named: "104")!)]
        setupCollectionViewLayouts()
    }
    
    func setupCollectionViewLayouts() {
            let categoryLayout = UICollectionViewFlowLayout()
            categoryLayout.scrollDirection = .horizontal
            categoryCollectionView.setCollectionViewLayout(categoryLayout, animated: false)
            
            let cardLayout = UICollectionViewFlowLayout()
            cardLayout.scrollDirection = .vertical
            cardCollectionView.setCollectionViewLayout(cardLayout, animated: false)
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
            cell.PriceLabel.text = "₹ \(card.price)/hr"
            cell.ImageView.image =  card.imageName
            cell.hostLabel.text = "Hosted by \(card.host)"
            cell.ratingLabel.text = "\(card.rating)"
            setOriginalPrice(card.oldPrice, for: cell)
            return cell
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView==categoryCollectionView{
            return CGSize(width: 100, height: 40)
        }else{
            let numberOfColumns: CGFloat = 2
                        let padding: CGFloat = 10 // Adjust space between items
                        let totalSpacing = (numberOfColumns + 1) * padding
                        let itemWidth = (collectionView.frame.size.width - totalSpacing) / numberOfColumns
                        return CGSize(width: itemWidth, height: 172)
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            if collectionView == categoryCollectionView {
                return 8.0
            } else {
                return 10.0 
            }
        }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return 10.0
        }
    func generateSectionForCards() -> NSCollectionLayoutSection {
        let numberOfColumns: CGFloat = 2
            let padding: CGFloat = 10 // Adjust space between items
            let totalSpacing = (numberOfColumns + 1) * padding
            let itemWidth = (cardCollectionView.frame.size.width - totalSpacing) / numberOfColumns
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(172))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            
            // Define the group size for the two-column layout
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(172))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item]) // Two items per row
            
            group.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0)
            group.interItemSpacing = .fixed(padding) // Adjust spacing between items in a row
            
            // Create the section with the defined group
            let section = NSCollectionLayoutSection(group: group)
            
            // Specify the section's orthogonal scrolling behavior (no horizontal scrolling in this case)
            section.orthogonalScrollingBehavior = .none
            
            return section    }
    func setOriginalPrice(_ originalPrice: String?, for cell: CardCell) {
        guard let originalPrice = originalPrice else { return }
        
        let price = "₹\(originalPrice)"
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.red,
            .font: UIFont.systemFont(ofSize: 14, weight: .light)
        ]
        let attributedPrice = NSAttributedString(string: price, attributes: attributes)
        cell.OrigianlPriceLabel.attributedText = attributedPrice
    }


}
