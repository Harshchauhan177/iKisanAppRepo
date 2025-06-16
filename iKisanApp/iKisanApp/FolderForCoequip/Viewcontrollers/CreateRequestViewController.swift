import UIKit

class CreateRequestViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UISearchBarDelegate, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var calendarLabel: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // Remove hardcoded categories and use a property
    private var categories: [String] = []
    var isFromHomeViewController = false
    var card:[Equipment]=[] 
    var filteredCard: [Equipment] = []
    var numberOfColumns: CGFloat = 2
    var selectedCategory:String?
    var selectedDate: Date?
    var selectedSuggestion: String?
     var selectedCalendarDate: Date?
    private var calendarView: UICalendarView?
    var dataController: DataController!
    


    private func setupInitialState() {
        // Set initial category
        if selectedCategory == nil && !categories.isEmpty {
            selectedCategory = "Combine"  // Set to Combine by default
        }
        
        setupCollectionViewLayouts()

        // Set initial date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM"
        dateLabel.text = dateFormatter.string(from: Date())
        
        // Select initial category
        if let category = selectedCategory,
           let index = categories.firstIndex(of: category) {
            categoryCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .left)
            filterCardsByCategory()
        }
        
        updateCategorySelection()
        categoryCollectionView.reloadData()
        cardCollectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Apply search filter if suggestion exists
        if let suggestion = selectedSuggestion,
           !suggestion.isEmpty,
           let searchBarRef = searchBar {
            searchBarRef.text = suggestion
            applySearchFilter()
        }
        
        // Reapply category filter
        if let category = selectedCategory {
            filterCardsByCategory()
        }
        
        // Set today's date if no date is selected
        let dateToUse = selectedCalendarDate ?? Date()
        selectedCalendarDate = dateToUse
        filteredCard = card.filter { isEquipmentAvailable(on: dateToUse, for: $0) }
        cardCollectionView.reloadData()
        
        // Update date label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateLabel.text = dateFormatter.string(from: dateToUse)
        
        // Update UI
        updateCategorySelection()
        cardCollectionView.reloadData()
    }
    func applySearchFilter() {
      
        guard isViewLoaded,
              let categoryCollectionViewRef = categoryCollectionView,
              let cardCollectionViewRef = cardCollectionView else {
            return
        }
        
        if let searchText = selectedSuggestion {
            card = dataController.getAllEquipment()
            filteredCard = card.filter { 
                $0.name.lowercased().contains(searchText.lowercased()) 
            }
            selectedCategory = nil
            categoryCollectionViewRef.reloadData()
            cardCollectionViewRef.reloadData()
        }
    }



    @objc private func doneButtonTapped() {
        dismiss(animated: true) {
            // Update the date label with selected date or today's date
            let dateToUse = self.selectedCalendarDate ?? Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            self.dateLabel.text = dateFormatter.string(from: dateToUse)
        }
    }
    // Add this property to store the selected date
    var selectedDateForInfo: Date = Date()  // Initialize with today's date
    
    // Update the dateSelection method to store the selected date
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents) else { return }
        selectedCalendarDate = date
        selectedDateForInfo = date  // Store the selected date
        
        // Dismiss the calendar view controller
        dismiss(animated: true) {
            // Update the date label with the selected date
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd MMM yyyy"
            self.dateLabel.text = dateFormatter.string(from: date)
            
            // Filter equipment based on availability
            self.filteredCard = self.card.filter { self.isEquipmentAvailable(on: date, for: $0) }
            self.cardCollectionView.reloadData()
        }
    }
  
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        searchBar.delegate = self

        searchBar.backgroundColor = .clear
        searchBar.searchBarStyle = .minimal
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear
        }
        
        // Register cells
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        cardCollectionView.register(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        
        // Load data
        if let dataController = dataController {
            categories = dataController.getCategories()
            card = dataController.getAllEquipment()
            
            // Set initial search text if coming from suggestion
            if let suggestion = selectedSuggestion {
                searchBar.text = suggestion
                filteredCard = card.filter { 
                    $0.name.lowercased().contains(suggestion.lowercased()) 
                }
            } else {
                filteredCard = card
            }
        } else {
            showAlert(message: "System error: Please try again later")
        }
        
        DispatchQueue.main.async {
            self.setupInitialState()
        }
    }




    @IBAction func calendarbuttonTapped(_ sender: Any) {
        let calendarVC = UIViewController()
        calendarVC.view.backgroundColor = UIColor(white: 0, alpha: 0.3)
        calendarVC.modalPresentationStyle = .overCurrentContext
        calendarVC.modalTransitionStyle = .crossDissolve
        
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 12
        containerView.translatesAutoresizingMaskIntoConstraints = false
        calendarVC.view.addSubview(containerView)
        
        let calendar = UICalendarView()
        calendar.calendar = .current
        calendar.locale = .current
        calendar.fontDesign = .rounded
        calendar.delegate = self
        calendar.backgroundColor = .white
        calendar.layer.cornerRadius = 12
        
        // Configure calendar appearance
        let dateSelection = UICalendarSelectionSingleDate(delegate: self)
        let defaultDate = selectedCalendarDate ?? Date()
        let components = Calendar.current.dateComponents([.year, .month, .day], from: defaultDate)
        dateSelection.selectedDate = components
        calendar.selectionBehavior = dateSelection
        
        // Set date range and disable past dates
        let today = Calendar.current.startOfDay(for: Date())
        calendar.availableDateRange = DateInterval(start: today, end: .distantFuture)
        
        // Enable multi-month scrolling
        calendar.visibleDateComponents = components
        
        calendar.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(calendar)
        
        let monthLabel = UILabel()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        monthLabel.text = dateFormatter.string(from: defaultDate)
        monthLabel.font = .systemFont(ofSize: 18, weight: .medium)
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(monthLabel)
        
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: calendarVC.view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: calendarVC.view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 320),
            containerView.heightAnchor.constraint(equalToConstant: 400), // Increased height for full month view
            
            monthLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            monthLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            
            calendar.topAnchor.constraint(equalTo: monthLabel.bottomAnchor, constant: 16),
            calendar.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            calendar.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            calendar.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
        
        present(calendarVC, animated: true)
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
    func isEquipmentAvailable(on date: Date, for equipment: Equipment) -> Bool {
        return equipment.isAvailable(on: date)
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
            
            // Fix 1: Handle both URL and local images
            if card.equipmentImage.hasPrefix("http") {
                // Load remote image using ImageCache utility
                cell.ImageView.loadImage(from: card.equipmentImage)
            } else {
                // Try loading local image with fallbacks
                if let image = UIImage(named: card.equipmentImage) {
                    cell.ImageView.image = image
                } else if let typeImage = UIImage(named: card.type) {
                    // Fallback to equipment type image
                    cell.ImageView.image = typeImage
                } else {
                    // Final fallback to a numbered image
                    cell.ImageView.image = UIImage(named: "1")
                }
            }
            
            // Fix 2: Clean provider name display
            cell.hostLabel.text = "Hosted by \(card.providerName ?? "Unknown")"
            
            cell.ratingLabel.text = "\(card.rating)"
            setOriginalPrice("\(card.realPricePerHour)", for: cell)
            cell.layer.cornerRadius = 10
            return cell
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            selectedCategory = categories[indexPath.row]
            categoryCollectionView.reloadData()
            filterCardsByCategory()
        } else if collectionView == cardCollectionView {
            let selectedCard = filteredCard[indexPath.row]
            guard let dataController = self.dataController else {
                showAlert(message: "System error: Please try again")
                return
            }
            
            let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
            if let equipmentDescVC = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
                equipmentDescVC.equipment = selectedCard
                equipmentDescVC.bookingSource = isFromHomeViewController ? .coEquip : .home
                equipmentDescVC.loadViewIfNeeded()
                equipmentDescVC.selectedDate = selectedCalendarDate ?? Date()
                
                navigationController?.pushViewController(equipmentDescVC, animated: true)
            }
        }
        
            func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
                if let dateComponents = dateComponents,
                   let date = Calendar.current.date(from: dateComponents) {
                    selectedCalendarDate = date
                    
                    // Update the date label
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "dd MMM yyyy"
                    dateLabel.text = dateFormatter.string(from: date)
                    
                    // Dismiss the calendar
                    dismiss(animated: true)
                }
            }
            
            func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
                return nil
            }
        
    }
    
    private func updateCategorySelection() {
        for (_, cell) in categoryCollectionView.visibleCells.enumerated() {
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
        if let infoVC = segue.destination as? InfoTableViewController {
            infoVC.date = selectedCalendarDate ?? Date()
            infoVC.cardData = sender as? Equipment
            infoVC.dataController = dataController
        }
    }

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
