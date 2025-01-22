

import UIKit

class CreateRequestViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var categories = ["Combine","Rice","Wheat","soyabean","Irrigation","Other"]
    var card:[CardData]=[]
    var numberOfColumns: CGFloat = 2
    
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
        let layout = UICollectionViewFlowLayout()
                layout.scrollDirection = .vertical
                cardCollectionView.setCollectionViewLayout(layout, animated: false)
                updateItemSize()
        }
    func updateItemSize() {
            let padding: CGFloat = 10
            let totalSpacing = (numberOfColumns + 1) * padding
            let itemWidth = (cardCollectionView.frame.size.width - totalSpacing) / numberOfColumns
            let itemHeight: CGFloat = 172
            
            if let layout = cardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
                layout.invalidateLayout()
            }
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
            cell.layer.cornerRadius=10
            return cell
            
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView==categoryCollectionView{
            return CGSize(width: 100, height: 40)
        }else{
            let numberOfColumns: CGFloat = 2
                    let padding: CGFloat = 10
                    let totalSpacing = (numberOfColumns + 1) * padding
                    let itemWidth = (collectionView.bounds.size.width - totalSpacing) / numberOfColumns
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
        let padding: CGFloat = 10
        let totalSpacing = (numberOfColumns + 1) * padding
        let itemWidth = (cardCollectionView.frame.size.width - totalSpacing) / numberOfColumns
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(itemWidth), heightDimension: .absolute(172))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(172))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item, item])
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 8.0)
        group.interItemSpacing = .fixed(padding)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .none
        
        return section
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
            let isLandscape = size.width > size.height
            numberOfColumns = isLandscape ? 3 : 2
            coordinator.animate(alongsideTransition: { _ in
                self.updateItemSize()
            }, completion: nil)
        }
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
