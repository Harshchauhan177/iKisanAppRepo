import UIKit

class CreateRequestViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    

    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var calendarLabel: UIButton!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var cardCollectionView: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var categories = ["Combine","Rice","Wheat","Soyabean","Irrigation","Other"]
    var card:[Equipment]=[]
    var filteredCard: [Equipment] = []
    var numberOfColumns: CGFloat = 2
    var selectedCategory:String?
    var selectedDate: Date?
    var selectedSuggestion: String?
    private var selectedCalendarDate: Date?
    private var calendarView: UICalendarView?
    var dataController: DataController? {
        didSet {
            print("DataController was set in CreateRequestViewController: \(dataController != nil)")
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        searchBar.delegate = self
        
        // Customize search bar appearance
        searchBar.backgroundColor = .clear
        searchBar.searchBarStyle = .minimal
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear
        }
        
        // Setup collection views
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        cardCollectionView.register(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        
        // Load initial data
        if let dataController = dataController {
            card = dataController.getAllEquipment()
            
            // If we have a selected suggestion, apply the filter
            if let suggestion = selectedSuggestion {
                filteredCard = card.filter { 
                    $0.name.lowercased().contains(suggestion.lowercased()) 
                }
            } else {
                filteredCard = card
            }
            
            print("📱 Loaded \(card.count) total cards, \(filteredCard.count) filtered")
        } else {
            print("⚠️ DataController not initialized")
            showAlert(message: "System error: Please try again later")
        }
        
        // Move setupInitialState() after all setup is complete
        DispatchQueue.main.async {
            self.setupInitialState()
        }
    }
    private func setupInitialState() {
        // Set default category to Combine if not already set
        if selectedCategory == nil {
            selectedCategory = "Combine"
        }
        setupCollectionViewLayouts()

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        dateLabel.text = dateFormatter.string(from: Date())

        // Select the appropriate category cell
        if let category = selectedCategory,
           let index = categories.firstIndex(of: category) {
            categoryCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .left)
            filterCardsByCategory()
        }
        
        // Update UI
        updateCategorySelection()
        categoryCollectionView.reloadData()
        cardCollectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Update search bar with selected suggestion if available
        if let suggestion = selectedSuggestion,
           !suggestion.isEmpty,
           let searchBarRef = searchBar {
            searchBarRef.text = suggestion
            applySearchFilter()
        }
    }
    
    // Apply search filter based on selected suggestion or search bar text
    func applySearchFilter() {
        guard let dataController = dataController else {
            print("⚠️ DataController not available")
            return
        }
        
        // Only proceed if view is loaded and outlets are connected
        guard isViewLoaded,
              let categoryCollectionViewRef = categoryCollectionView,
              let cardCollectionViewRef = cardCollectionView else {
            print("⚠️ View not loaded or collections not connected")
            return
        }
        
        if let searchText = selectedSuggestion {
            // Get all equipment and filter based on the search text
            card = dataController.getAllEquipment()
            filteredCard = card.filter { 
                $0.name.lowercased().contains(searchText.lowercased()) 
            }
            
            // Update UI
            selectedCategory = nil // Reset category selection since we're filtering by search
            
            // Use the safely unwrapped references
            categoryCollectionViewRef.reloadData()
            cardCollectionViewRef.reloadData()
            
            print("🔍 Filtered cards count: \(filteredCard.count) for search text: \(searchText)")
        }
    }



    @IBAction func calendarbuttonTapped(_ sender: Any) {
        let calendarVC = UIViewController()
        calendarVC.view.backgroundColor = .white
        
        // Setup calendar view
        let calendar = UICalendarView()
        calendar.calendar = .current
        calendar.locale = .current
        calendar.fontDesign = .rounded
        calendar.delegate = self
        calendar.backgroundColor = .white
        
       
        calendarView = calendar
        
        // Setup selection behavior
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendar.selectionBehavior = selection
        
        // Add calendar to view
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendarVC.view.addSubview(calendar)
        
        // Setup done button
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.backgroundColor = .white
        calendarVC.view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            // Calendar constraints
            calendar.leadingAnchor.constraint(equalTo: calendarVC.view.leadingAnchor, constant: 10),
            calendar.trailingAnchor.constraint(equalTo: calendarVC.view.trailingAnchor, constant: -10),
            calendar.topAnchor.constraint(equalTo: calendarVC.view.topAnchor, constant: 20),
            calendar.heightAnchor.constraint(equalToConstant: 420),
            
            // Done button constraints
            doneButton.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 10),
            doneButton.centerXAnchor.constraint(equalTo: calendarVC.view.centerXAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 44),
            doneButton.widthAnchor.constraint(equalToConstant: 100)
        ])
        
        calendarVC.modalPresentationStyle = .pageSheet
        if let sheet = calendarVC.sheetPresentationController {
            sheet.detents = [.custom { context in
                return 500
            }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        
        present(calendarVC, animated: true)
    }
    
    @objc private func doneButtonTapped() {
        if let date = selectedCalendarDate {
            selectedDate = date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            dateLabel.text = dateFormatter.string(from: date)
            filterCardsByDate()
        }
        dismiss(animated: true)
    }
    
    // MARK: - Calendar Delegate Methods
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents) else { return }
        selectedCalendarDate = date
    }
    
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        return nil
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
    func isEquipmentAvailable(on date: Date, for card: Equipment) -> Bool {
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
        if searchText.isEmpty {
            filteredCard = dataController?.getAllEquipment() ?? []
        } else {
            filteredCard = dataController?.filterEquipment(by: searchText) ?? []
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
            let category = categories[indexPath.row]
            cell.titleLabel.text = categories[indexPath.row]
            cell.titleLabel.textAlignment = .center
            cell.layer.cornerRadius = 17
            cell.layer.borderWidth = 1
            cell.backgroundColor = .white
            cell.layer.borderColor = UIColor.lightGray.cgColor
            
            if category == selectedCategory {
                cell.backgroundColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
                cell.titleLabel.textColor = .white
            } else {
                cell.backgroundColor = .white
                cell.titleLabel.textColor = .black
                cell.layer.borderWidth = 1
                cell.layer.borderColor = UIColor.lightGray.cgColor
            }
            
            return cell
        } else {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
            let card = filteredCard[indexPath.row]
            cell.TitleLabel.text = card.name
            cell.PriceLabel.text = "₹\(card.pricePerHour)/hr"
            cell.ImageView.image = UIImage(named: card.equipmentImage)
            cell.hostLabel.text = "Hosted by Ram Pal"//"Hosted by \(card.providerID)"
            cell.ratingLabel.text = "\(card.rating)"
            setOriginalPrice("\(card.realPricePerHour)", for: cell)
            cell.layer.cornerRadius = 10

            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            selectedCategory = categories[indexPath.row]
            categoryCollectionView.reloadData() // Reload to update all cell colors
            filterCardsByCategory()
        } else if collectionView == cardCollectionView {
            let selectedCard = filteredCard[indexPath.row]
            
            // Verify dataController exists
            guard let dataController = self.dataController else {
                print("⚠️ Error: DataController is nil")
                showAlert(message: "System error: Please try again")
                return
            }
            
            // Create InfoTableViewController programmatically
            let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
            if let infoTableVC = storyboard.instantiateViewController(withIdentifier: "InfoTableViewController") as? InfoTableViewController {
                // Configure the view controller using the configure method
                infoTableVC.configure(with: selectedCard, 
                                    dataController: dataController,
                                    date: selectedDate ?? Date())
                
                // Push the view controller
                navigationController?.pushViewController(infoTableVC, animated: true)
            }
        }
    }
    
    private func updateCategorySelection() {
        for (index, cell) in categoryCollectionView.visibleCells.enumerated() {
            guard let categoryCell = cell as? CategoryCell else { continue }
            if categoryCell.titleLabel.text == selectedCategory {
                categoryCell.backgroundColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
                categoryCell.titleLabel.textColor = .white
            } else {
                categoryCell.backgroundColor = .white
                categoryCell.titleLabel.textColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
            }
        }
    }

    func filterCardsByCategory() {
        guard let selectedCategory = selectedCategory else {
            filteredCard = card
            return
        }
        
        if selectedCategory == "Combine" {
            filteredCard = card
        } else {
            filteredCard = card.filter { $0.name.lowercased().contains(selectedCategory.lowercased()) }
        }
        
        cardCollectionView?.reloadData()
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

    private func setOriginalPrice(_ originalPrice: String?, for cell: CardCell) {
        guard let originalPrice = originalPrice else { return }
        let price = "₹\(originalPrice)"
        let attributes: [NSAttributedString.Key: Any] = [
            .strikethroughStyle: NSUnderlineStyle.single.rawValue,
            .strikethroughColor: UIColor.darkGray
        ]
        let attributedPrice = NSAttributedString(string: price, attributes: attributes)
        cell.OrigianlPriceLabel.attributedText = attributedPrice
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInfoDetails" {
            if let destinationVC = segue.destination as? InfoTableViewController {
                if let selectedCard = sender as? Equipment {
                    destinationVC.cardData = selectedCard
                    // Pass the selected date if available, otherwise use current date
                    destinationVC.date = selectedDate ?? Date()
                }
            }
        } else if segue.identifier == "goToInfoTableView",
                  let infoTableVC = segue.destination as? InfoTableViewController {
            infoTableVC.dataController = self.dataController
            if let equipment = sender as? Equipment {
                infoTableVC.cardData = equipment
            }
        }
    }

    // Add this helper method to show alerts
    private func showAlert(message: String) {
        let alert = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
