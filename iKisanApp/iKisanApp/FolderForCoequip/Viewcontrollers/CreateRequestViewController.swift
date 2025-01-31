

import UIKit

class CreateRequestViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate {
    
    

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var calendarLabel: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var categories = ["Combine","Rice","Wheat","soyabean","Irrigation","Other"]
    var card:[CardData]=[]
    var filteredCard: [CardData] = []
    var numberOfColumns: CGFloat = 2
    var selectedCategory:String?
    var selectedDate: Date?
    var selectedSuggestion: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        categoryCollectionView.delegate=self
        categoryCollectionView.dataSource=self
        cardCollectionView.delegate=self
        cardCollectionView.dataSource=self
        searchBar.delegate=self
        
            
        if let suggestion = selectedSuggestion {
                    searchBar.text = suggestion
                }
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        cardCollectionView.register(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        
        card=[CardData(title: "Rice Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Ram Pal", imageName: UIImage(named: "101")!),CardData(title: "Rice Harvester", price: "1500", oldPrice:"2250", rating: "4.5", host: "Veer singh", imageName: UIImage(named: "102")!),CardData(title: "Harvester", price: "4000", oldPrice:"5000", rating: "4.5", host: "Muskesh", imageName: UIImage(named: "103")!),CardData(title: "soyabean", price: "700", oldPrice:"1750", rating: "4.5", host: "Raj Pal", imageName: UIImage(named: "104")!)]
        
        
        selectedCategory = categories.first
        setupCollectionViewLayouts()
        categoryCollectionView.reloadData()
            categoryCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .left)
        highlightSelectedCategory()
        filterCardsByCategory()
    }
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//            searchBar.resignFirstResponder()
//        }
    
    @IBAction func calendarbuttonTapped(_ sender: Any) {
        let calendarVC = UIViewController()
            calendarVC.view.backgroundColor = .white

            let datePicker = UIDatePicker()
            datePicker.datePickerMode = .date
            datePicker.frame = CGRect(x: 20, y: 100, width: calendarVC.view.frame.width - 40, height: 200)
            calendarVC.view.addSubview(datePicker)

            let doneButton = UIButton(type: .system)
            doneButton.setTitle("Done", for: .normal)
            doneButton.frame = CGRect(x: 20, y: 310, width: calendarVC.view.frame.width - 40, height: 50)
            doneButton.addTarget(self, action: #selector(dateSelected(_:)), for: .touchUpInside)
            calendarVC.view.addSubview(doneButton)

            self.present(calendarVC, animated: true, completion: nil)
    }
    
    @objc func dateSelected(_ sender: UIButton) {
        if let datePicker = sender.superview?.subviews.compactMap({ $0 as? UIDatePicker }).first {
            selectedDate = datePicker.date
            updateDateLabel()
            filterCardsByDate()
            dismiss(animated: true, completion: nil)
        }
    }
    func updateDateLabel() {
        if let selectedDate = selectedDate {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            dateLabel.text = "Selected Date: \(dateFormatter.string(from: selectedDate))"
        }
    }
    func filterCardsByDate() {
        if let selectedDate = selectedDate {
            filteredCard = card.filter { isEquipmentAvailable(on: selectedDate, for: $0) }
        } else {
            filteredCard = card
        }
        cardCollectionView.reloadData()
    }
    func isEquipmentAvailable(on date: Date, for card: CardData) -> Bool {
        return true
    }
    func highlightSelectedCategory() {
        for cell in categoryCollectionView.visibleCells {
            if let categoryCell = cell as? CategoryCell {
                if categoryCell.titleLabel.text == selectedCategory {
                    categoryCell.backgroundColor = UIColor.green
                } else {
                    categoryCell.backgroundColor = UIColor.white
                }
            }
        }
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            if !searchText.isEmpty {
                filteredCard = card.filter { $0.title.lowercased().contains(searchText.lowercased()) }
            } else {
                filterCardsByCategory()
            }
            cardCollectionView.reloadData()
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
            if collectionView == categoryCollectionView {
                return categories.count
            } else {
                return filteredCard.count
            }
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if collectionView == categoryCollectionView {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
                cell.titleLabel.text = categories[indexPath.row]
                cell.titleLabel.textAlignment = .center
                cell.layer.cornerRadius = 17
                cell.layer.borderWidth = 1
                cell.backgroundColor = .white
                cell.layer.borderColor = UIColor.lightGray.cgColor
                return cell
            } else {
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
                let card = filteredCard[indexPath.row]
                cell.TitleLabel.text = card.title
                cell.PriceLabel.text = "₹ \(card.price)/hr"
                cell.ImageView.image = card.imageName
                cell.hostLabel.text = "Hosted by \(card.host)"
                cell.ratingLabel.text = "\(card.rating)"
                setOriginalPrice(card.oldPrice, for: cell)
                cell.layer.cornerRadius = 10

                return cell
            }
        }

        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            if collectionView == cardCollectionView {
                    let selectedCard = filteredCard[indexPath.row]
                    performSegue(withIdentifier: "showInfoDetails", sender: selectedCard)
                }
            if collectionView == categoryCollectionView {
                    selectedCategory = categories[indexPath.row]
                    for cell in collectionView.visibleCells {
                        if let categoryCell = cell as? CategoryCell {
                            if categoryCell.titleLabel.text == selectedCategory {
                                categoryCell.backgroundColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
                                categoryCell.titleLabel.textColor = .white
                            } else {
                                categoryCell.backgroundColor = UIColor.white
                                categoryCell.titleLabel.textColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
                            }
                        }
                    }

                    filterCardsByCategory()
            }
           
        }

        func filterCardsByCategory() {
            if let selectedCategory = selectedCategory {
                if selectedCategory == "Combine" {
                    filteredCard = card
                } else {
                    filteredCard = card.filter { $0.title.contains(selectedCategory) }
                }
            } else {
                filteredCard = card
            }
            cardCollectionView.reloadData()
        }
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            if collectionView == categoryCollectionView {
                return CGSize(width: 100, height: 40)
            } else {
                let padding: CGFloat = 8
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

        func setOriginalPrice(_ originalPrice: String?, for cell: CardCell) {
            guard let originalPrice = originalPrice else { return }

            let price = "₹\(originalPrice)"
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .strikethroughColor: UIColor.darkGray
//                .font: UIFont.systemFont(ofSize: 14, weight: .light)
            ]
            let attributedPrice = NSAttributedString(string: price, attributes: attributes)
            cell.OrigianlPriceLabel.attributedText = attributedPrice
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInfoDetails" {
            if let destinationVC = segue.destination as? InfoTableViewController {
                if let selectedCard = sender as? CardData {
                    destinationVC.cardData = selectedCard
                }
            }
        }
    }

    }
