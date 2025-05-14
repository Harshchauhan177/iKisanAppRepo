import UIKit
import Foundation

// Helper extension for DateFormatter
extension DateFormatter {
    func apply(_ configurator: (DateFormatter) -> Void) -> DateFormatter {
        configurator(self)
        return self
    }
}

class CreateRequestViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var calendarLabel: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cardCollectionView: UICollectionView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    
    
    private var categories: [String] = []
    private var card: [Equipment] = []
    private var filteredCard: [Equipment] = []
    private var numberOfColumns: CGFloat = 2
    private var selectedCategory: String?
    private var selectedDate: Date?
    var selectedSuggestion: String?  // Made public for access from SearchViewController
    private var selectedCalendarDate: Date?
    private var calendarView: UICalendarView?
    var dataController: DataController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionViews()
        setupSearchBar()
        setupMockUserIfNeeded()
        loadData()
    }
    
    // Setup a mock user with location if none exists
    private func setupMockUserIfNeeded() {
        // We'll only work with currentUser since AuthManager is causing issues
        if currentUser.shared.user == nil {
            print("No currentUser found, creating mock user for CreateRequestVC")
            
            // Create a mock location for testing
            let mockLocation = Location(
                latitude: 28.4595,
                longitude: 77.5021,
                address: "Murshadpur, Greater Noida, U.P"
            )
            
            let mockUser = User(
                userID: UUID(),
                name: "Test User",
                email: "test@example.com",
                phone: "1234567890",
                location: mockLocation,
                selectedCrops: [],
                fieldArea: 5.0
            )
            
            currentUser.shared.user = mockUser
            print("Created mock user with location: \(mockLocation.address ?? "Unknown")")
        }
    }
    
    private func setupCollectionViews() {
        categoryCollectionView.delegate = self
        categoryCollectionView.dataSource = self
        cardCollectionView.delegate = self
        cardCollectionView.dataSource = self
        
        categoryCollectionView.register(UINib(nibName: "CategoryCell", bundle: nil), forCellWithReuseIdentifier: "CategoryCell")
        cardCollectionView.register(UINib(nibName: "CardCell", bundle: nil), forCellWithReuseIdentifier: "CardCell")
        
        setupCollectionViewLayouts()
    }
    
    private func setupSearchBar() {
        searchBar.delegate = self
        searchBar.backgroundColor = .clear
        searchBar.searchBarStyle = .minimal
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = .clear
        }
    }
    
    private func loadData() {
        guard let dataController = dataController else {
            showAlert(message: "System error: Please try again later")
            return
        }
        
        // Load categories from backend
        categories = dataController.getCategories()
        
        // Load all equipment
        card = dataController.getAllEquipment()
        
        // Initially keep all equipment unfiltered
        filteredCard = card
        
        // Default to first category
        selectedCategory = categories.first
        
        DispatchQueue.main.async {
            self.setupInitialState()
        }
    }

    private func setupInitialState() {
        setupCollectionViewLayouts()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        dateLabel.text = dateFormatter.string(from: selectedDate ?? Date())
        
        if let category = selectedCategory,
           let index = categories.firstIndex(of: category) {
            categoryCollectionView.selectItem(at: IndexPath(row: index, section: 0), animated: false, scrollPosition: .left)
        }
        
        // Apply initial filters
        applyAllFilters()
        
        updateCategorySelection()
        categoryCollectionView.reloadData()
        cardCollectionView.reloadData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If we have a suggestion from search, apply it
        if let suggestion = selectedSuggestion, !suggestion.isEmpty {
            searchBar.text = suggestion
            applyAllFilters()
        }
    }

    func applySearchFilter() {
        guard isViewLoaded else { return }
        
        if let searchText = selectedSuggestion, !searchText.isEmpty {
            // Set the search bar text
            searchBar.text = searchText
            
            // Apply all filters
            applyAllFilters()
        }
    }
    
    // New consolidated filter method
    private func applyAllFilters() {
        // Start with all equipment
        var filtered = dataController.getAllEquipment()
        
        // Apply search filter if we have a search term
        if let searchText = searchBar.text, !searchText.isEmpty {
            filtered = filtered.filter { equipment in
                equipment.name.lowercased().contains(searchText.lowercased()) ||
                equipment.type.lowercased().contains(searchText.lowercased())
            }
        }
        
        // Apply category filter if not showing all equipment
        if let category = selectedCategory, category != "Combine" {
            filtered = filtered.filter { equipment in
                equipment.type.lowercased().contains(category.lowercased())
            }
        }
        
        // Apply date filter if a date is selected
        if let date = selectedDate {
            filtered = filtered.filter { equipment in
                dataController.isEquipmentAvailable(on: date, for: equipment)
            }
        }
        
        // Update the filtered cards
        filteredCard = filtered
        
        // Reload the collection view
        categoryCollectionView.reloadData()
        cardCollectionView.reloadData()
    }

    @IBAction func calendarbuttonTapped(_ sender: Any) {
        presentCalendarView()
    }
    
    private func presentCalendarView() {
        let calendarVC = UIViewController()
        calendarVC.view.backgroundColor = .white
        
        let calendar = UICalendarView()
        calendar.calendar = .current
        calendar.locale = .current
        calendar.fontDesign = .rounded
        calendar.delegate = self
        calendar.backgroundColor = .white
        
        calendarView = calendar
        let selection = UICalendarSelectionSingleDate(delegate: self)
        calendar.selectionBehavior = selection
        
        setupCalendarConstraints(in: calendarVC, calendar: calendar)
        presentCalendarSheet(calendarVC)
    }
    
    private func setupCalendarConstraints(in viewController: UIViewController, calendar: UICalendarView) {
        calendar.translatesAutoresizingMaskIntoConstraints = false
        viewController.view.addSubview(calendar)
        
        let doneButton = UIButton(type: .system)
        doneButton.setTitle("Done", for: .normal)
        doneButton.translatesAutoresizingMaskIntoConstraints = false
        doneButton.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneButton.backgroundColor = .white
        viewController.view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            calendar.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor, constant: 10),
            calendar.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor, constant: -10),
            calendar.topAnchor.constraint(equalTo: viewController.view.topAnchor, constant: 20),
            calendar.heightAnchor.constraint(equalToConstant: 420),
            doneButton.topAnchor.constraint(equalTo: calendar.bottomAnchor, constant: 10),
            doneButton.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
            doneButton.heightAnchor.constraint(equalToConstant: 44),
            doneButton.widthAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    private func presentCalendarSheet(_ viewController: UIViewController) {
        viewController.modalPresentationStyle = .pageSheet
        if let sheet = viewController.sheetPresentationController {
            sheet.detents = [.custom { _ in 500 }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 20
        }
        present(viewController, animated: true)
    }
    
    @objc private func doneButtonTapped() {
        guard let date = selectedCalendarDate else {
            print("⚠️ No date was selected, dismissing calendar without changes")
            dismiss(animated: true)
            return
        }
        
        print("🔎 DEBUG: Calendar selection done button tapped")
        print("🔎 Raw date from calendar: \(date)")
        
        // Extract only the date components (year, month, day)
        var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        components.hour = 12
        components.minute = 0
        components.second = 0
        
        if let normalizedDate = Calendar.current.date(from: components) {
            // Update the selectedDate property with the normalized date
            selectedDate = normalizedDate
            
            // Update the UI immediately
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            let dateString = dateFormatter.string(from: normalizedDate)
            dateLabel.text = dateString
            
            print("🔎 DEBUG Calendar Selection:")
            print("  - Raw date: \(date)")
            print("  - Normalized date: \(normalizedDate)")
            print("  - Display string: \(dateString)")
            print("  - Date components: Y:\(components.year!) M:\(components.month!) D:\(components.day!)")
            
            // Apply all filters including the new date
            applyAllFilters()
        } else {
            print("⚠️ Failed to create normalized date!")
        }
        
        dismiss(animated: true)
    }

    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        print("🔎 DEBUG: Calendar date selection called")
        
        guard let dateComponents = dateComponents else { 
            print("⚠️ Date selection failed: No date components")
            return 
        }
        
        print("🔎 DEBUG: Raw date components selected: \(dateComponents)")
        
        // Add time component (noon) to avoid timezone issues
        var fullComponents = dateComponents
        fullComponents.hour = 12
        fullComponents.minute = 0
        fullComponents.second = 0
        
        guard let date = Calendar.current.date(from: fullComponents) else {
            print("⚠️ Date selection failed: Could not create date from components")
            return
        }
        
        // Save the selected date
        selectedCalendarDate = date
        
        // CRITICAL CHANGE: Also update selectedDate immediately
        // This ensures the date is captured even if user doesn't tap "Done"
        selectedDate = date
        
        // Update dateLabel immediately so user gets visual feedback
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, d MMM"
        let dateString = dateFormatter.string(from: date)
        
        // Print detailed debugging information
        print("🔎 DEBUG: Date selection in calendar:")
        print("  - Components: Y:\(fullComponents.year!) M:\(fullComponents.month!) D:\(fullComponents.day!)")
        print("  - Created date: \(date)")
        print("  - Display string: \(dateString)")
        
        // Update UI immediately for better feedback
        DispatchQueue.main.async {
            self.dateLabel.text = dateString
            print("📅 Updated date label immediately: \(dateString)")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // When search text changes, update the selected suggestion
        selectedSuggestion = searchText.isEmpty ? nil : searchText
        
        // Apply all filters
        applyAllFilters()
    }

    // MARK: - Collection View Layout Methods
    
    private func setupCollectionViewLayouts() {
        let categoryLayout = UICollectionViewFlowLayout()
        categoryLayout.scrollDirection = .horizontal
        categoryCollectionView.setCollectionViewLayout(categoryLayout, animated: false)
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        cardCollectionView.setCollectionViewLayout(layout, animated: false)
        
        updateItemSize()
    }

    private func updateItemSize() {
        let padding: CGFloat = 10
        let totalSpacing = (numberOfColumns + 1) * padding
        let itemWidth = (cardCollectionView.frame.size.width - totalSpacing) / numberOfColumns
        let itemHeight: CGFloat = 172
        
        if let layout = cardCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
            layout.invalidateLayout()
        }
    }

    // MARK: - Collection View Data Source & Delegate Methods

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == categoryCollectionView ? categories.count : filteredCard.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == categoryCollectionView {
            return configureCategoryCell(collectionView, at: indexPath)
        } else {
            return configureCardCell(collectionView, at: indexPath)
        }
    }
    
    private func configureCategoryCell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategoryCell", for: indexPath) as! CategoryCell
        let category = categories[indexPath.row]
        
        cell.titleLabel.text = category
        cell.titleLabel.textAlignment = .center
        cell.layer.cornerRadius = 17
        cell.layer.borderWidth = 1
        
        if category == selectedCategory {
            cell.backgroundColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
            cell.titleLabel.textColor = .white
        } else {
            cell.backgroundColor = .white
            cell.titleLabel.textColor = .black
            cell.layer.borderColor = UIColor.lightGray.cgColor
        }
        
        return cell
    }
    
    private func configureCardCell(_ collectionView: UICollectionView, at indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! CardCell
        let equipment = filteredCard[indexPath.row]
        
        cell.TitleLabel.text = equipment.name
        cell.PriceLabel.text = "₹\(equipment.pricePerHour)/hr"
        cell.ImageView.image = UIImage(named: equipment.equipmentImage)
        cell.hostLabel.text = "Hosted by \(equipment.providerName ?? "Unknown")"
        cell.ratingLabel.text = "\(equipment.rating)"
        setOriginalPrice("\(equipment.realPricePerHour)", for: cell)
        cell.layer.cornerRadius = 10
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == categoryCollectionView {
            handleCategorySelection(at: indexPath)
        } else {
            handleCardSelection(at: indexPath)
        }
    }
    
    private func handleCategorySelection(at indexPath: IndexPath) {
        selectedCategory = categories[indexPath.row]
        updateCategorySelection()
        categoryCollectionView.reloadData()
        
        // Apply all filters when category changes
        applyAllFilters()
    }
    
    private func handleCardSelection(at indexPath: IndexPath) {
        let selectedEquipment = filteredCard[indexPath.row]
        print("🔍 User selected equipment: \(selectedEquipment.name)")
        
        // CRITICAL: Normalize the selected date first
        var normalizedDate: Date?
        if let selectedDate = selectedDate {
            // Use the explicitly selected date from calendar
            var components = Calendar.current.dateComponents([.year, .month, .day], from: selectedDate)
            components.hour = 12
            components.minute = 0
            components.second = 0
            
            if let date = Calendar.current.date(from: components) {
                normalizedDate = date
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd"
                print("📅 Using selected date: \(df.string(from: date))")
            } else {
                normalizedDate = selectedDate
                print("⚠️ Date normalization failed, using original selected date")
            }
        } else {
            // No date selected, use current date
            let now = Date()
            var components = Calendar.current.dateComponents([.year, .month, .day], from: now)
            components.hour = 12
            components.minute = 0
            components.second = 0
            
            if let date = Calendar.current.date(from: components) {
                normalizedDate = date
                // Also set selectedDate for consistency
                selectedDate = date
                print("📅 No date selected, using normalized current date")
            } else {
                normalizedDate = now
                selectedDate = now
                print("⚠️ Date normalization failed, using raw current date")
            }
        }
        
        // NAVIGATION PATH 1: Try to navigate through EquipmentDescriptionTableViewController first
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let equipmentDescVC = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
            // Configure the VC with selected equipment
            equipmentDescVC.equipment = selectedEquipment
            equipmentDescVC.bookingSource = .coEquip
            equipmentDescVC.dataController = self.dataController
            
            // CRITICAL: Pass the normalized date
            equipmentDescVC.selectedDate = normalizedDate
            
            let df = DateFormatter()
            df.dateFormat = "E, d MMM"
            print("📅 Passing date to EquipmentDescVC: \(df.string(from: normalizedDate!))")
            
            // Push the new view controller
            navigationController?.pushViewController(equipmentDescVC, animated: true)
            return
        }
        
        // NAVIGATION PATH 2: Fallback to direct navigation to InfoTableViewController
        print("⚠️ EquipmentDescriptionTableViewController not found, using direct navigation to InfoTableViewController")
        
        guard let dataController = self.dataController else {
            showAlert(message: "System error: Please try again")
            return
        }
        
        // Get user's location
        var locationToPass = "Murshadpur, Greater Noida, U.P" // Default fallback
        
        // Try AuthManager first
        if let authUser = AuthManager.shared.currentUser {
            if let address = authUser.address, !address.isEmpty {
                locationToPass = address
                print("👉 Using location from AuthManager: \(locationToPass)")
            } else if let location = authUser.location, let address = location.address, !address.isEmpty {
                locationToPass = address
                print("👉 Using location from AuthManager location object: \(locationToPass)")
            } else {
                print("⚠️ AuthManager user has no address, trying currentUser")
            }
        } else {
            print("⚠️ No user in AuthManager, trying currentUser")
        }
        
        // Try currentUser as fallback
        if locationToPass == "Murshadpur, Greater Noida, U.P", let user = currentUser.shared.user {
            if let address = user.location.address, !address.isEmpty {
                locationToPass = address
                print("👉 Using location from currentUser: \(locationToPass)")
            } else {
                print("⚠️ currentUser has no address, using default location: \(locationToPass)")
            }
        }
        
        // Log the final values
        let df = DateFormatter()
        df.dateFormat = "E, d MMM"
        print("📋 Final values being passed to InfoTableVC:")
        print("   - Date: \(df.string(from: normalizedDate!))")
        print("   - Location: \(locationToPass)")
        print("   - Equipment: \(selectedEquipment.name)")
        
        // Instantiate and configure InfoTableViewController
        let coequipStoryboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
        if let infoTableVC = coequipStoryboard.instantiateViewController(withIdentifier: "InfoTableViewController") as? InfoTableViewController {
            // ⚠️ Clear any existing date first
            infoTableVC.date = nil
            
            // Use the explicit setter methods
            infoTableVC.setDate(normalizedDate!)
            infoTableVC.setLocation(locationToPass)
            
            // Configure with the same date
            infoTableVC.configure(with: selectedEquipment, dataController: dataController, date: normalizedDate!)
            
            // Navigate to InfoTableVC
            print("➡️ Pushing InfoTableVC to navigation stack")
            navigationController?.pushViewController(infoTableVC, animated: true)
        } else {
            print("❌ ERROR: Could not instantiate InfoTableViewController!")
        }
    }
    
    private func updateCategorySelection() {
        categoryCollectionView.visibleCells.forEach { cell in
            guard let categoryCell = cell as? CategoryCell else { return }
            if categoryCell.titleLabel.text == selectedCategory {
                categoryCell.backgroundColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
                categoryCell.titleLabel.textColor = .white
            } else {
                categoryCell.backgroundColor = .white
                categoryCell.titleLabel.textColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
            }
        }
    }

    // This method is no longer needed as we use applyAllFilters
    private func filterCardsByCategory() {
        applyAllFilters()
    }

    // This method is no longer needed as we use applyAllFilters
    func filterCardsByDate() {
        applyAllFilters()
    }

    // MARK: - Collection View Flow Layout Delegate Methods

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
        return collectionView == categoryCollectionView ? 8.0 : 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    // MARK: - Helper Methods

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

