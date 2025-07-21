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
    
    // Add properties to track current filters
    private var currentSearchText: String = ""
    private var isSearchActive: Bool = false

    private func setupInitialState() {
        // Set initial category - use "All" instead of "Combine" for better UX
        if selectedCategory == nil && !categories.isEmpty {
            selectedCategory = "All"
        }
        
        setupCollectionViewLayouts()

        // Set initial date format
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, dd MMM"
        dateLabel.text = dateFormatter.string(from: Date())
        
        // Load all equipment initially
        card = dataController.getAllEquipment()
        
        // Apply initial filters
        applyAllFilters()
        
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
            currentSearchText = suggestion
            isSearchActive = true
        }
        
        // Set today's date if no date is selected
        let dateToUse = selectedCalendarDate ?? Date()
        selectedCalendarDate = dateToUse
        
        // Update date label
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM yyyy"
        dateLabel.text = dateFormatter.string(from: dateToUse)
        
        // Apply all filters together
        applyAllFilters()
        
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
        
        if let searchText = selectedSuggestion, !searchText.isEmpty {
            currentSearchText = searchText
            isSearchActive = true
            
            // Don't clear selectedCategory - let them work together
            applyAllFilters()
            
            categoryCollectionViewRef.reloadData()
            cardCollectionViewRef.reloadData()
        }
    }

    // New method to apply all filters together
    private func applyAllFilters() {
        var results = card
        
        // First apply search filter if active
        if isSearchActive && !currentSearchText.isEmpty {
            results = results.filter { equipment in
                equipment.name.lowercased().contains(currentSearchText.lowercased()) ||
                equipment.type.lowercased().contains(currentSearchText.lowercased()) ||
                equipment.description?.lowercased().contains(currentSearchText.lowercased()) == true
            }
        }
        
        // Then apply category filter
        if let category = selectedCategory, category != "All" {
            results = results.filter { equipment in
                return filterEquipmentByCategory(equipment, category: category)
            }
        }
        
        // Finally apply date filter
        if let dateToUse = selectedCalendarDate {
            results = results.filter { isEquipmentAvailable(on: dateToUse, for: $0) }
        }
        
        filteredCard = results
    }
    
    // Improved category filtering logic
    private func filterEquipmentByCategory(_ equipment: Equipment, category: String) -> Bool {
        let equipmentName = equipment.name.lowercased()
        let equipmentType = equipment.type.lowercased()
        let categoryLower = category.lowercased()
        
        switch categoryLower {
        case "combine":
            return equipmentName.contains("combine") || 
                   equipmentType.contains("combine") ||
                   equipmentName.contains("harvest") && (equipmentType.contains("combine") || equipmentName.contains("combine"))
            
        case "rice":
            return equipmentName.contains("rice") || 
                   equipmentType.contains("rice") ||
                   equipmentName.contains("paddy") ||
                   equipmentType.contains("paddy")
            
        case "wheat":
            return equipmentName.contains("wheat") || 
                   equipmentType.contains("wheat") ||
                   (equipmentName.contains("grain") && !equipmentName.contains("rice"))
            
        case "soyabean", "soybean":
            return equipmentName.contains("soya") || 
                   equipmentName.contains("soy") ||
                   equipmentType.contains("soya") ||
                   equipmentType.contains("soy")
            
        case "irrigation":
            return equipmentName.contains("irrigation") || 
                   equipmentType.contains("irrigation") ||
                   equipmentName.contains("water") ||
                   equipmentName.contains("pump") ||
                   equipmentType.contains("pump")
            
        case "other":
            // For "other", show equipment that doesn't match the main categories
            let mainCategories = ["combine", "rice", "wheat", "soya", "irrigation", "pump", "paddy"]
            return !mainCategories.contains { keyword in
                equipmentName.contains(keyword) || equipmentType.contains(keyword)
            }
            
        default:
            return true
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
            
            // Apply all filters including the new date
            self.applyAllFilters()
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
            // Update categories to include "All" and improve the list
            categories = ["All", "Combine", "Rice", "Wheat", "Soyabean", "Irrigation", "Other"]
            card = dataController.getAllEquipment()
            
            // Set initial search text if coming from suggestion
            if let suggestion = selectedSuggestion {
                searchBar.text = suggestion
                currentSearchText = suggestion
                isSearchActive = true
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
    
    // Updated search bar delegate method
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        currentSearchText = searchText
        isSearchActive = !searchText.isEmpty
        
        // Apply all filters when search text changes
        applyAllFilters()
        cardCollectionView.reloadData()
    }

    func setupCollectionViewLayouts() {
        let categoryLayout = UICollectionViewFlowLayout()
        categoryLayout.scrollDirection = .horizontal
        // UPDATED LEFT MARGIN: Reduced from 24 to 16 since we increased the collection view leading constraint from 10 to 20
        // Total margin is now 20 (collection view) + 16 (flow layout) = 36 points, ensuring "All" button is fully visible
        categoryLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        categoryLayout.minimumInteritemSpacing = 12
        categoryLayout.minimumLineSpacing = 12
        categoryCollectionView.setCollectionViewLayout(categoryLayout, animated: false)
        categoryCollectionView.showsHorizontalScrollIndicator = false
        
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
            // Apply all filters when category changes
            applyAllFilters()
            cardCollectionView.reloadData()
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

    // Remove the old filterCardsByCategory method and replace with improved version
    func filterCardsByCategory() {
        // This method is now replaced by applyAllFilters()
        applyAllFilters()
        cardCollectionView?.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == categoryCollectionView {
            // MARK: - Filter Buttons (All, Combine, Rice, etc.) Height and Appearance Configuration
            // This section controls the dynamic sizing and appearance of category filter buttons
            // The buttons automatically adjust their width based on text content while maintaining
            // consistent height for proper touch targets according to HIG guidelines
            
            // Calculate dynamic width based on text content
            let category = categories[indexPath.row]
            let font = UIFont.preferredFont(forTextStyle: .headline)
            let textSize = category.size(withAttributes: [.font: font])
            
            // Add horizontal padding: 12pt left + 12pt right (from XIB constraints) + 8pt extra for visual comfort
            let width = textSize.width + 24 + 8 // 8pt extra for visual comfort
            
            // FILTER BUTTON HEIGHT: Set to 40pt for proper touch targets per HIG guidelines
            // This ensures all filter buttons have consistent height regardless of text length
            let height: CGFloat = 40
            
            return CGSize(width: max(width, 60), height: height) // Minimum width of 60pt for consistency
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
