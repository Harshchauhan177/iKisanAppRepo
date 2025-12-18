//  PrebookingViewController.swift
//  iKisanApp
//  Created by Batch - 1 on 15/01/25.

import UIKit

class PrebookingViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, preBookingEquipmentSectionAddPreBookCollectionViewCellDelegate,PreBookingSection3CellDelegate {
    
    
    var targetSection: Int? // Store the section we want to scroll to

    
    var hasAddPreBook : Bool = false //
    var selectedIndexPath: IndexPath?
    @IBOutlet weak var collectionView: UICollectionView!
    
    // Making dataController public so it can be set from MainTabBarController
    public var dataController: DataController?
    private var recommendedEquipments: [Equipment] = []
    private var availableEquipments: [Equipment] = []
    internal var faqs: [FAQ] = []
    private var selectedDate: Date?
    private var searchedEquipments: [Equipment] = [] // Changed from single equipment to array
    private var allEquipment: [Equipment] = []
    private var filteredEquipment: [Equipment] = []
    
    // Add grouped equipment data structures for grouping by name
    private var groupedEquipments: [String: [Equipment]] = [:]
    private var groupedSearchResults: [String: [Equipment]] = [:]
    
    // Pull-to-refresh control
    private var refreshControl = UIRefreshControl()
    
    private var searchSuggestions: [Equipment] = []
    // Removed custom searchTableView in favor of standard UISearchController results
    private var isShowingSuggestions = false
    
    var preBookings: [Booking] = []
    var preBookingEquipments: [Equipment] = []
    
    var hasPreBookings: Bool {
        return !preBookings.isEmpty
    }
    
    // Update the Section enum to better reflect our layout
    enum Section: Int, CaseIterable {
        case recommended = 0
        case calendar = 1
        case available = 2
        case prebookings = 3
        case faq = 4
        
        var headerTitle: String {
            switch self {
            case .recommended:
                return "Recommended"
            case .calendar:
                return "Select Date"
            case .available:
                return "Available Equipment"
            case .prebookings:
                return "Your Prebookings"
            case .faq:
                return "FAQ"
            }
        }
        
        func getAvailableHeaderTitle(for equipmentName: String?) -> String {
            if let name = equipmentName {
                return "Available \(name)"
            }
            return "Available Equipment"
        }
    }
    
    // Add these properties if not already present
    private var searchController: UISearchController!
    private var allEquipments: [Equipment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure dataController is initialized (set by MainTabBarController)
        guard dataController != nil else {
            print("❌ Error: DataController not initialized in PrebookingViewController")
            // This shouldn't happen if MainTabBarController is properly set up
            return
        }
        
        // Load data now that dataController is confirmed
        loadData()
        
        setupCollectionView()
        setupSearchController()
        setupNotifications()
        
        // Ensure search controller behavior preserves query
        if #available(iOS 16.0, *) {
            navigationItem.preferredSearchBarPlacement = .stacked
        }
        
        // Load initial data
        loadPreBookings()
        
        // Previously scrolled to target section, but auto-scrolling has been disabled
        // Keeping targetSection for reference in case needed in future
        if targetSection != nil {
            // No auto-scrolling - removed as requested
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Check if there's an active search
        let hasActiveSearch = !(searchController.searchBar.text?.isEmpty ?? true)
        
        // Reset available equipment section state only if no search is active
        if !hasActiveSearch {
            hasAddPreBook = false
            availableEquipments = []
            selectedDate = nil
            searchedEquipments = []
        } else {
            // If there's an active search, preserve the search state
            print("Preserving search state for: \(searchController.searchBar.text ?? "")")
            print("Searched equipments count: \(searchedEquipments.count)")
            
            // Ensure calendar is properly configured with searched equipment
            if !searchedEquipments.isEmpty {
                DispatchQueue.main.async { [weak self] in
                    if let calendarCell = self?.collectionView.cellForItem(at: IndexPath(item: 0, section: Section.calendar.rawValue)) as? preBookingCalanderCollectionViewCell {
                        calendarCell.configure(with: self?.searchedEquipments, dataController: self?.dataController)
                        print("Reconfigured calendar with \(self?.searchedEquipments.count ?? 0) searched equipments")
                    }
                }
            }
        }
        
        // Remove existing observer before adding new one to prevent duplicates
        NotificationCenter.default.removeObserver(
            self,
            name: .equipmentAvailabilityChanged,
            object: nil
        )
        
        // Add observer for equipment availability changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEquipmentAvailability(_:)),
            name: .equipmentAvailabilityChanged,
            object: nil
        )
        
        // Add observer for booking list refresh (when bookings are canceled)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(refreshPreBookings),
            name: NSNotification.Name("RefreshBookingsList"),
            object: nil
        )
        
        // Refresh prebookings data and FAQs
        Task { [weak self] in
            // Refresh FAQs from Supabase
            if let dataController = self?.dataController {
                await dataController.refreshFAQsFromDatabase()
            }
            
            await MainActor.run {
                self?.loadData() // Reload all data including FAQs
                self?.loadPreBookings()
                
                // Only reload collection view if no active search to preserve search state
                if self?.searchedEquipments.isEmpty ?? true {
                    self?.collectionView.reloadData()
                } else {
                    // For active search, only reload sections that don't affect calendar
                    let sectionsToReload: [Int] = [
                        Section.recommended.rawValue,
                        Section.prebookings.rawValue,
                        Section.faq.rawValue
                    ].compactMap { sectionIndex in
                        // Only reload if section exists in current layout
                        if sectionIndex < self?.collectionView.numberOfSections ?? 0 {
                            return sectionIndex
                        }
                        return nil
                    }
                    
                    if !sectionsToReload.isEmpty {
                        self?.collectionView.reloadSections(IndexSet(sectionsToReload))
                    }
                }
            }
        }
    }
    
    private func loadData() {
        guard let dataController = dataController else { return }
        
        recommendedEquipments = dataController.getRecommendedEquipments()
        
        // Only update availableEquipments if there's no active search to preserve search context
        if searchedEquipments.isEmpty {
            availableEquipments = dataController.getAvailableEquipments()
        }
        
        faqs = dataController.getPreBookingFAQs()
        
        collectionView.reloadData()
    }
    
    func loadPreBookings() {
        guard let dataController = dataController else { return }
        
        // Force refresh bookings from the database to ensure we have the latest data
        Task {
            // Refresh bookings from the database
            await dataController.refreshBookingsFromDatabase()
            
            // Get all bookings and filter prebookings on the main thread
            await MainActor.run {
                let allBookings = dataController.getUpcomingBookings()
                preBookings = allBookings.filter {
                    $0.bookingType == .prebooking && $0.source == .prebooking
                }
                
                // Get equipment details for each prebooking
                preBookingEquipments = preBookings.compactMap { booking in
                    dataController.getEquipment(byId: booking.equipmentID)
                }
                
                // Reload the collection view to reflect changes
                self.collectionView.reloadData()
                
                // Log the current prebookings for debugging
                print("Current prebookings after refresh: \(self.preBookings.count)")
            }
        }
        preBookingEquipments = preBookings.compactMap { booking in
            dataController.getEquipment(byId: booking.equipmentID)
        }
        
        // Reload the entire collection view to reflect changes
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    // Add synchronous version for immediate updates
    private func loadPreBookingsSync() {
        guard let dataController = dataController else { return }
        
        // Get all bookings and filter prebookings synchronously
        let allBookings = dataController.getUpcomingBookings()
        preBookings = allBookings.filter {
            $0.bookingType == .prebooking && $0.source == .prebooking
        }
        
        // Get equipment details for each prebooking
        preBookingEquipments = preBookings.compactMap { booking in
            dataController.getEquipment(byId: booking.equipmentID)
        }
        
        print("Sync loaded prebookings: \(preBookings.count)")
    }
    
    @objc private func handlePreBookingAdded(_ notification: Notification) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Force immediate refresh of prebookings data synchronously
            self.loadPreBookingsSync()
            
            // Force update calendar decorations
            let calendarIndexPath = IndexPath(item: 0, section: Section.calendar.rawValue)
            if let calendarCell = self.collectionView.cellForItem(at: calendarIndexPath) as? preBookingCalanderCollectionViewCell {
                calendarCell.refreshCalendarDecorations()
            }
            
            // Reload the entire collection view to ensure sections are properly displayed
            self.collectionView.reloadData()
        }
    }
    
    @objc private func handlePrebookingDateSelected(_ notification: Notification) {
        guard let selectedDate = notification.userInfo?["date"] as? Date else { return }
        
        // Find the first prebooking that matches the selected date
        if let matchingBookingIndex = preBookings.firstIndex(where: { booking in
            Calendar.current.isDate(booking.bookingDate, inSameDayAs: selectedDate)
        }) {
            // No auto-scrolling
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        var sectionCount = 0
        
        // Always include recommended section
        sectionCount += 1 // Section 0: Recommended
        
        // Calendar section
        sectionCount += 1 // Section 1: Calendar
        
        // Available equipment section (if hasAddPreBook is true)
        if hasAddPreBook {
            sectionCount += 1 // Section 2: Available
        }
        
        // Prebookings section (if hasPreBookings is true)
        if hasPreBookings {
            sectionCount += 1 // Section 3: Prebookings
        }
        
        // FAQ section always last
        sectionCount += 1 // Section 4: FAQ
        
        return sectionCount
    }
    
    // Changed from private to internal to allow access from extensions
    internal func getSectionType(for index: Int) -> Section {
        var currentIndex = 0
        
        // Recommended section is always first
        if index == currentIndex {
            return .recommended
        }
        currentIndex += 1
        
        // Calendar section is always second
        if index == currentIndex {
            return .calendar
        }
        currentIndex += 1
        
        // Available equipment section (if present)
        if hasAddPreBook {
            if index == currentIndex {
                return .available
            }
            currentIndex += 1
        }
        
        // Prebookings section (if present)
        if hasPreBookings {
            if index == currentIndex {
                return .prebookings
            }
            currentIndex += 1
        }
        
        // FAQ section is always last
        return .faq
    }
    
    // Method to get section index from section type
    internal func getSectionIndex(for section: Section) -> Int {
        var index = 0
        
        // Always include recommended section
        if section == .recommended {
            return index
        }
        index += 1
        
        // Calendar section
        if section == .calendar {
            return index
        }
        index += 1
        
        // Available equipment section (if hasAddPreBook is true)
        if hasAddPreBook {
            if section == .available {
                return index
            }
            index += 1
        }
        
        // Prebookings section (if hasPreBookings is true)
        if hasPreBookings {
            if section == .prebookings {
                return index
            }
            index += 1
        }
        
        // FAQ section always last
        return index
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let sectionType = getSectionType(for: section)
        
        switch sectionType {
        case .recommended:
            return recommendedEquipments.count
        case .calendar:
            return 1
        case .available:
            return hasAddPreBook ? availableEquipments.count : 0
        case .prebookings:
            return hasPreBookings ? preBookings.count : 0
        case .faq:
            return faqs.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let sectionType = getSectionType(for: indexPath.section)
        
        switch sectionType {
        case .recommended:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! preBookingRecommendedForYouCollectionViewCell
            let equipment = recommendedEquipments[indexPath.row]  // Get single equipment
            cell.configure(with: equipment)  // Pass single equipment
            cell.layer.cornerRadius = 15
            return cell
        
        case .calendar:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Second", for: indexPath) as! preBookingCalanderCollectionViewCell
            
            // Get all prebooking dates
            let prebookingDates = preBookings.map { $0.bookingDate }
            
            // Always use searched equipment if available, otherwise use empty array
            // This ensures calendar only shows availability for searched equipment
            let equipmentToShow = searchedEquipments.isEmpty ? [] : searchedEquipments
            
            // Debug logging
            print("Calendar cell configuration:")
            print("- Search bar text: '\(searchController.searchBar.text ?? "")'")
            print("- Searched equipments count: \(searchedEquipments.count)")
            print("- Equipment to show count: \(equipmentToShow.count)")
            if !equipmentToShow.isEmpty {
                print("- Equipment names: \(equipmentToShow.map { $0.name })")
            }
            cell.configure(
                with: equipmentToShow,
                dataController: dataController,
                prebookingDates: prebookingDates
            )
            cell.layer.cornerRadius = 15
            return cell
        
        case .available:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Fifth", for: indexPath) as! preBookingEquipmentSectionAddPreBookCollectionViewCell
            if indexPath.row < availableEquipments.count {
                let equipment = availableEquipments[indexPath.row]
                cell.configure(with: equipment)
                cell.delegate = self
            }
            cell.layer.cornerRadius = 15
            return cell
        
        case .prebookings:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Third", for: indexPath) as! yourPrebookingsSection
            let booking = preBookings[indexPath.row]
            if let equipment = preBookingEquipments[safe: indexPath.row] {
                cell.configure(with: booking, equipment: equipment)
                cell.delegate = self
            }
            cell.equipmentImageView.layer.cornerRadius = 7
            cell.layer.cornerRadius = 15
            return cell
        
        case .faq:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Fourth", for: indexPath) as! preBookingFAQSectionCollectionViewCell
            // Configure the cell with the FAQ data from Supabase
            if indexPath.row < faqs.count {
                let faq = faqs[indexPath.row]
                cell.configure(with: faq, index: indexPath.row)
                cell.delegate = self
            }
            // No need to set corner radius as it's handled in the cell's layoutSubviews method
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                       viewForSupplementaryElementOfKind kind: String,
                       at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        let headerView = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind,
            withReuseIdentifier: "SectionHeader",
            for: indexPath
        )
        
        // Configure header view
        headerView.subviews.forEach { $0.removeFromSuperview() }
        
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
        titleLabel.textColor = .label
        
        let sectionType = getSectionType(for: indexPath.section)
        if sectionType == .available && !availableEquipments.isEmpty {
            // For available section, show the equipment name if it's a grouped result
            let equipmentName = availableEquipments.first?.name
            titleLabel.text = sectionType.getAvailableHeaderTitle(for: equipmentName)
        } else {
            titleLabel.text = sectionType.headerTitle
        }
        
        headerView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -8)
        ])
        
        return headerView
    }
    
    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else {
                // Return a default section if self is nil
                return self?.createDefaultSection() ?? NSCollectionLayoutSection(
                    group: NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .estimated(44)
                        ),
                        subitems: []
                    )
                )
            }
            
            let sectionType = self.getSectionType(for: sectionIndex)
            switch sectionType {
            case .recommended:
                return self.createRecommendedSection()
            case .calendar:
                return self.createCalendarSection()
            case .available:
                return self.createAvailableSection()
            case .prebookings:
                return self.createPrebookingsSection()
            case .faq:
                return self.createFAQSection()
            }
        }
        return layout
    }
    
    func generatePreBookingSection1Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.9))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(200))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            return section
        }
    
    func generatePreBookingSection2Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(420) // Match the new calendar height
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.01),
            heightDimension: .absolute(420) // Match the new calendar height
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
        return section
    }
    
    func generatePreBookingSection3Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Set fixed height for a single item
        let itemHeight: CGFloat = 105 // Height of one card
        let spacing: CGFloat = 10
        
        // Calculate number of items
        let numberOfItems = preBookings.count
        // Total height = (item height × number of items) + (spacing × (number of items - 1))
        let totalHeight = (itemHeight * CGFloat(numberOfItems)) + (spacing * CGFloat(max(0, numberOfItems - 1)))
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.92),
            heightDimension: .absolute(totalHeight)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: numberOfItems > 0 ? numberOfItems : 1 // Ensure at least 1 item for empty state
        )
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
        return section
    }
    
    func generatePreBookingSection4Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.922),
            heightDimension: .absolute(180)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: 3
        )
        
        group.interItemSpacing = .fixed(5.0)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
        return section
    }
    
    func generatePreBookingSectionAddPreBookLayout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Set fixed height for a single item
        let itemHeight: CGFloat = 105 // Height of one card
        let spacing: CGFloat = 10
        
        // Calculate number of items
        let numberOfItems = availableEquipments.count
        // Total height = (item height × number of items) + (spacing × (number of items - 1))
        let totalHeight = (itemHeight * CGFloat(numberOfItems)) + (spacing * CGFloat(max(0, numberOfItems - 1)))
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.92),
            heightDimension: .absolute(totalHeight)
        )
        
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: numberOfItems
        )
        
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 0,
            leading: 16,
            bottom: 0,
            trailing: 16
        )
        return section
    }
    
    func userSearched() {
        // Reset the view state when search is initiated
        hasAddPreBook = false
        searchedEquipments = []
        selectedDate = nil
        
        // Reload collection view to reflect changes
        collectionView.reloadData()
        
        // Ensure search bar is visible and ready for input
        searchController.searchBar.becomeFirstResponder()
    }
    
    
    @IBAction func searchPreBookingButtonTapped(_ sender: Any) {
        
    //hasAddPreBook = true
//        collectionView.reloadData()
        
       userSearched()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        let sectionType = Section(rawValue: indexPath.section) ?? .recommended // Use enum for section type

        var selectedEquipment: Equipment?

        switch sectionType {
        case .recommended:
            // Recommended Section
            if indexPath.row < recommendedEquipments.count {
                selectedEquipment = recommendedEquipments[indexPath.row]
            }
        case .calendar:
            // Calendar Section - Not tappable, but for safety
            print("Tapped Calendar section - not expected here")
            return
        case .available:
            // Available Equipment Section - Not tappable, but for safety
            print("Tapped Available Equipment section - not expected here")
            return
        case .prebookings:
            // Prebookings Section - Not tappable, but for safety
            print("Tapped Prebookings section - not expected here")
            return
        case .faq:
            // FAQ Section - Not tappable, but for safety
            print("Tapped FAQ section - not expected here")
            return
        }

        // Proceed only if selectedEquipment is valid
        if let selectedEquipment = selectedEquipment {
            print("PrebookingViewController - Selected equipment: \(selectedEquipment.name)")

            let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil) // Assuming EquipmentDescriptionTableViewController is in Tab1Home storyboard
            if let controller = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
                controller.equipment = selectedEquipment
                controller.bookingSource = .prebooking
                navigationController?.pushViewController(controller, animated: true)
            }
        } else {
            print("Error: Could not retrieve selected equipment for section \(sectionType), row \(indexPath.row)")
        }
    }
    
    func didTapViewButton(on cell: preBookingEquipmentSectionAddPreBookCollectionViewCell) {
        // Find the index path of the tapped cell
        guard let indexPath = collectionView.indexPath(for: cell),
              let selectedDate = selectedDate else { return }
        
        // Get the specific equipment from the available equipments array
        guard indexPath.row < availableEquipments.count else { return }
        let equipment = availableEquipments[indexPath.row]
        
        // Get the storyboard and view controller
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let reviewController = storyboard.instantiateViewController(withIdentifier: "ReviewBookingTableViewController") as? ReviewBookingTableViewController {
            // Pass the required data
            reviewController.equipment = equipment
            reviewController.selectedDate = selectedDate
            reviewController.bookingSource = .prebooking // Set the source
            
            // Push the view controller
            navigationController?.pushViewController(reviewController, animated: true)
        }
    }
    

    func scrollToSectionHeader(section: Int) {
        guard let collectionView = self.collectionView else { return }
        
        // Adjust section index based on visible sections
        var adjustedSection = section
        if !hasAddPreBook && section > Section.calendar.rawValue {
            adjustedSection -= 1
        }
        
        let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        let headerSize = layout?.headerReferenceSize.height ?? 0
        
        // Get the section header layout info
        let indexPath = IndexPath(item: 0, section: adjustedSection)
        if let attributes = collectionView.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: indexPath) {
            
            let headerY = attributes.frame.origin.y - collectionView.contentInset.top
            // NOTE: Auto-scrolling has been disabled
            // collectionView.setContentOffset(CGPoint(x: 0, y: headerY - headerSize), animated: true)
        }
    }

    @objc func refreshPreBookings() {
        // Refresh prebookings data when a booking is canceled
        DispatchQueue.main.async { [weak self] in
            self?.loadPreBookings()
            self?.collectionView.reloadData()
        }
    }
    
    @objc private func handleEquipmentAvailability(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let date = userInfo["date"] as? Date,
              let isAvailable = userInfo["isAvailable"] as? Bool else {
            return
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        let selectedDay = Calendar.current.startOfDay(for: date)
        
        if isAvailable && selectedDay >= today {
            hasAddPreBook = true
            selectedDate = date
            
            // Use the available equipment group from the notification if available
            if let availableEquipmentGroup = userInfo["availableEquipmentGroup"] as? [Equipment] {
                // Only use equipment from the searched group to maintain search context
                if !searchedEquipments.isEmpty {
                    // Filter to only include equipment that was in the searched results
                    let searchedEquipmentIDs = Set(searchedEquipments.map { $0.equipmentID })
                    availableEquipments = availableEquipmentGroup.filter { equipment in
                        searchedEquipmentIDs.contains(equipment.equipmentID)
                    }
                } else {
                    availableEquipments = availableEquipmentGroup
                }
            } else {
                // Fallback: filter searched equipments by availability
                availableEquipments = searchedEquipments.filter { equipment in
                    equipment.isAvailable(on: date) &&
                    Calendar.current.startOfDay(for: date) >= today
                }
            }
        } else {
            hasAddPreBook = false
            availableEquipments = []
            selectedDate = nil
        }
        
        collectionView.reloadData()
    }
    
    private func setupCollectionView() {
        // Register cells with their correct identifiers
        let cellRegistrations: [(identifier: String, nibName: String)] = [
            ("First", "preBookingEquipmentSection1CollectionViewCell"),
            ("Second", "preBookingEquipmentSection2CollectionViewCell"),
            ("Third", "preBookingEquipmentSection3CollectionViewCell"),
            ("Fourth", "preBookingEquipmentSection4CollectionViewCell"),
            ("Fifth", "preBookingEquipmentSectionAddPreBookCollectionViewCell")
        ]
        
        // Register each cell type
        for registration in cellRegistrations {
            let nib = UINib(nibName: registration.nibName, bundle: nil)
            collectionView.register(nib, forCellWithReuseIdentifier: registration.identifier)
        }
        
        // Register header view
        collectionView.register(
            UICollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeader"
        )
        
        // Setup layout
        collectionView.setCollectionViewLayout(createLayout(), animated: false)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Setup pull-to-refresh
        setupRefreshControl()
    }
    
    // Setup refresh control
    private func setupRefreshControl() {
       
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }
    
    @objc private func refreshData() {
        print("Pull-to-refresh triggered in PrebookingViewController")
        // Start refresh animation
        refreshControl.beginRefreshing()
        
        // Reload data asynchronously
        Task {
            // Refresh all data
            await dataController?.refreshBookingsFromDatabase()
            await dataController?.refreshFAQsFromDatabase()
            
            // End refreshing on main thread
            await MainActor.run {
                // Reload all data
                loadData()
                loadPreBookings()
                refreshControl.endRefreshing()
                print("Refresh completed in PrebookingViewController")
            }
        }
    }
    
    private func setupSearchController() {
        // Create search results controller
        let resultsController = UITableViewController()
        resultsController.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchCell")
        resultsController.tableView.delegate = self
        resultsController.tableView.dataSource = self
        resultsController.tableView.backgroundColor = .init(red: 0.9216, green: 0.9216, blue: 0.9216, alpha: 1.0)
        
        // Initialize search controller with results controller
        searchController = UISearchController(searchResultsController: resultsController)
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search Equipment"
        searchController.obscuresBackgroundDuringPresentation = true
        
        // Standard HIG-compliant search bar behavior
        searchController.hidesNavigationBarDuringPresentation = true
        searchController.automaticallyShowsCancelButton = true
        
        // Set the search controller in navigation
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Ensure search presentation context is defined correctly
        definesPresentationContext = true
        
        // Load all equipment for search from backend
        loadAllEquipmentForSearch()
    }
    
    private func loadAllEquipmentForSearch() {
        // First try to load from data controller
        if let dataController = dataController {
            let localEquipments = dataController.getAllEquipment()
            
            // If we already have equipment locally, use it immediately
            if !localEquipments.isEmpty {
                self.allEquipments = localEquipments
                return // Skip network request if we have local data
            }
        }
        
        // Network request throttling - use a timestamp to prevent excessive calls
        let lastRequestKey = "lastEquipmentFetchTime"
        let minTimeBetweenRequests = 30.0 // seconds
        
        let now = Date()
        if let lastRequestTime = UserDefaults.standard.object(forKey: lastRequestKey) as? Date,
           now.timeIntervalSince(lastRequestTime) < minTimeBetweenRequests {
            print("Skipping equipment fetch - too soon since last request")
            return
        }
        
        // Then fetch from backend only if needed
        Task {
            do {
                // Save request timestamp
                UserDefaults.standard.set(now, forKey: lastRequestKey)
                
                // Fetch equipment from backend
                let requestManager = RequestManager.shared
                let equipments = await requestManager.fetchEquipments()
                
                // Update on main thread
                await MainActor.run {
                    if !equipments.isEmpty {
                        self.allEquipments = equipments
                    }
                }
            } catch {
                print("Error fetching equipment for search: \(error)")
            }
        }
    }
    
    private func setupNotifications() {
        // Remove any existing observers first
        NotificationCenter.default.removeObserver(self)
        
        // Add observers
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePreBookingAdded(_:)),
            name: .preBookingAdded,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePrebookingDateSelected(_:)),
            name: .prebookingDateSelected,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEquipmentAvailability(_:)),
            name: .equipmentAvailabilityChanged,
            object: nil
        )
    }
    
    // Update adjustSectionIndex to handle the dynamic sections properly
    private func adjustSectionIndex(_ section: Int) -> Int {
        var adjustedSection = section
        
        // If available equipment section is hidden and we're past its position
        if !hasAddPreBook && section >= Section.available.rawValue {
            adjustedSection -= 1
        }
        
        // If prebookings section is hidden and we're past its position
        if !hasPreBookings && section >= Section.prebookings.rawValue {
            adjustedSection -= 1
        }
        
        return adjustedSection
    }
    
    // Implement delegate method
    func didTapModifyButton(for booking: Booking, equipment: Equipment) {
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let reviewController = storyboard.instantiateViewController(withIdentifier: "ReviewBookingTableViewController") as? ReviewBookingTableViewController {
            reviewController.equipment = equipment
            reviewController.booking = booking
            reviewController.selectedDate = booking.bookingDate
            reviewController.isModifying = true
            reviewController.bookingSource = .prebooking
            reviewController.delegate = self
            navigationController?.pushViewController(reviewController, animated: true)
        }
    }
    
    // This duplicate method has been removed to fix the 'Invalid redeclaration' error
}

// MARK: - UISearchResultsUpdating
extension PrebookingViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text?.lowercased(),
              !searchText.isEmpty else {
            searchSuggestions = []
            (searchController.searchResultsController as? UITableViewController)?.tableView.reloadData()
            return
        }
        
        // If we have few equipment items, refresh from backend
        if allEquipments.count < 5 {
            loadAllEquipmentForSearch()
        }
        
        // Comprehensive search across all equipment fields
        let matchingEquipments = allEquipments.filter { equipment in
            equipment.name.lowercased().contains(searchText) ||
            equipment.type.lowercased().contains(searchText) ||
            equipment.description?.lowercased().contains(searchText) == true ||
            equipment.location.lowercased().contains(searchText)
        }
        
        // Group by name and show only one representative per group
        let groupedResults = groupEquipmentByName(matchingEquipments)
        searchSuggestions = getRepresentativeEquipmentNames(from: groupedResults).compactMap { name in
            getRepresentativeEquipment(for: name, from: groupedResults)
        }
        
        // Store grouped results for later use
        groupedSearchResults = groupedResults
        
        // Reload the search results table
        (searchController.searchResultsController as? UITableViewController)?.tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension PrebookingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath)
        let equipment = searchSuggestions[indexPath.row]
        
        // Configure cell to show only equipment name
        var content = cell.defaultContentConfiguration()
        content.text = equipment.name
        // Remove secondary text to show only the equipment name
        content.secondaryText = nil
        cell.contentConfiguration = content
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let selectedEquipment = searchSuggestions[indexPath.row]
        
        // Select the entire group of equipment with the same name
        searchedEquipments = getEquipmentGroup(for: selectedEquipment.name, from: groupedSearchResults)
        
        print("Search selection: \(selectedEquipment.name), found \(searchedEquipments.count) equipment entities")
        
        // Update search bar text with selected equipment name
        searchController.searchBar.text = selectedEquipment.name
        
        // Dismiss search controller
        searchController.dismiss(animated: true) {
            // Reset sections state
            self.hasAddPreBook = false
            self.availableEquipments = []
            self.selectedDate = nil
            
            // Update calendar with selected equipment group BEFORE reloading
            if let calendarCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: Section.calendar.rawValue)) as? preBookingCalanderCollectionViewCell {
                print("Configuring calendar with \(self.searchedEquipments.count) searched equipments before reload")
                calendarCell.configure(with: self.searchedEquipments, dataController: self.dataController)
            }
            
            // Use full reload instead of section-specific reload to avoid batch update issues
            self.collectionView.reloadData()
            
            print("Search context preserved: \(self.searchedEquipments.count) equipments")
        }
    }
}

// MARK: - UISearchBarDelegate
extension PrebookingViewController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Clear search state
        searchedEquipments = []
        searchSuggestions = []
        
        // Reset sections state
        hasAddPreBook = false
        availableEquipments = []
        selectedDate = nil
        
        // Reload collection view to reflect changes
        collectionView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        guard let query = searchBar.text, !query.isEmpty else { return }
        
        // Use proper search method from DataController and group results
        let rawSearchResults = dataController?.searchEquipment(query: query) ?? []
        let groupedResults = groupEquipmentByName(rawSearchResults)
        
        // Get all equipment from all groups for searchedEquipments
        searchedEquipments = Array(groupedResults.values.flatMap { $0 })
        
        // Dismiss search controller
        searchController.dismiss(animated: true) {
            if !self.searchedEquipments.isEmpty {
                print("Search button: Found \(self.searchedEquipments.count) equipments for query: \(query)")
                
                // Reset sections state
                self.hasAddPreBook = false
                self.availableEquipments = []
                self.selectedDate = nil
                
                // Update calendar with ALL searched equipment
                if let calendarCell = self.collectionView.cellForItem(at: IndexPath(item: 0, section: Section.calendar.rawValue)) as? preBookingCalanderCollectionViewCell {
                    print("Configuring calendar with all searched equipment")
                    calendarCell.configure(with: self.searchedEquipments, dataController: self.dataController)
                }
                
                // Show available section if any equipment is available today
                let today = Date()
                if self.searchedEquipments.contains(where: { $0.isAvailable(on: today) }) {
                    self.hasAddPreBook = true
                    self.availableEquipments = self.searchedEquipments.filter { $0.isAvailable(on: today) }
                }
                
                // Only reload calendar section to preserve search context
                let calendarSection = Section.calendar.rawValue
                self.collectionView.reloadSections(IndexSet([calendarSection]))
                
                print("Search context established: \(self.searchedEquipments.count) equipments")
            }
        }
    }
}

// Add notification name
extension Notification.Name {
    static let preBookingAdded = Notification.Name("preBookingAdded")
    static let prebookingDateSelected = Notification.Name("prebookingDateSelected")
}

// Add extension to handle booking updates
extension PrebookingViewController: ReviewBookingDelegate {
    func didModifyBooking(_ booking: Booking) {
        // Update the booking in data controller
        dataController?.updateBooking(booking)
        
        // Refresh the prebookings list
        if let dataController = dataController {
            preBookings = dataController.getPreBookings()
            preBookingEquipments = preBookings.compactMap { booking in
                dataController.getEquipment(byId: booking.equipmentID)
            }
        }
        
        // Instead of reloading just the prebookings section, reload the entire collection view
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
}

// MARK: - Collection View Layout & Supplementary Views
extension PrebookingViewController {
    private func createLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { [weak self] sectionIndex, _ in
            guard let self = self else {
                // Return a default section if self is nil
                return self?.createDefaultSection() ?? NSCollectionLayoutSection(
                    group: NSCollectionLayoutGroup.horizontal(
                        layoutSize: NSCollectionLayoutSize(
                            widthDimension: .fractionalWidth(1.0),
                            heightDimension: .estimated(44)
                        ),
                        subitems: []
                    )
                )
            }
            
            let sectionType = self.getSectionType(for: sectionIndex)
            switch sectionType {
            case .recommended:
                return self.createRecommendedSection()
            case .calendar:
                return self.createCalendarSection()
            case .available:
                return self.createAvailableSection()
            case .prebookings:
                return self.createPrebookingsSection()
            case .faq:
                return self.createFAQSection()
            }
        }
        return layout
    }
    
    private func createDefaultSection() -> NSCollectionLayoutSection {
        // Default section layout
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
        
        return section
    }
    
    private func createRecommendedSection() -> NSCollectionLayoutSection {
        // Item
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Group
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(0.9),
            heightDimension: .absolute(180)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        // Section
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPaging
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 10)
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // Add implementations for other section layouts
    private func createCalendarSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(420) // Increased from 400 to 420
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(440) // Increased from 420 to 440 to give extra space
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(
            top: 10,
            leading: 16,
            bottom: 10,
            trailing: 16
        )
        
        // Header
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    // Implement similar methods for available, prebookings, and FAQ sections
    private func createAvailableSection() -> NSCollectionLayoutSection {
        // Set fixed height for a single item
        let itemHeight: CGFloat = 105 // Height of one card
        let spacing: CGFloat = 10
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(itemHeight)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // Calculate number of items
        let numberOfItems = max(1, availableEquipments.count) // At least 1 for layout purposes
        
        // Total height = (item height × number of items) + (spacing × (number of items - 1))
        let totalHeight = (itemHeight * CGFloat(numberOfItems)) + (spacing * CGFloat(max(0, numberOfItems - 1)))
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(totalHeight)
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: groupSize,
            subitem: item,
            count: numberOfItems
        )
        group.interItemSpacing = .fixed(spacing)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createPrebookingsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(105)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(105)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 16, bottom: 10, trailing: 16)
        
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .estimated(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createFAQSection() -> NSCollectionLayoutSection {
        // Use fixed height for items like in iOS settings
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44) // Fixed height for items
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 0 // No spacing between cells like in iOS settings
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 16, bottom: 20, trailing: 16) // Group style insets
        
        // Add header to the section
        let headerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(44)
        )
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        section.boundarySupplementaryItems = [header]
        
        return section
    }
}

// MARK: - Equipment Grouping Helper Methods
    
    /// Groups equipment by their name into a dictionary
    private func groupEquipmentByName(_ equipments: [Equipment]) -> [String: [Equipment]] {
        return Dictionary(grouping: equipments) { $0.name }
    }
    
    /// Gets representative equipment names for display (one per group)
    private func getRepresentativeEquipmentNames(from groupedEquipments: [String: [Equipment]]) -> [String] {
        return Array(groupedEquipments.keys).sorted()
    }
    
    /// Gets the first equipment from a group (for display purposes)
    private func getRepresentativeEquipment(for name: String, from groupedEquipments: [String: [Equipment]]) -> Equipment? {
        return groupedEquipments[name]?.first
    }
    
    /// Gets all equipment in a group by name
    private func getEquipmentGroup(for name: String, from groupedEquipments: [String: [Equipment]]) -> [Equipment] {
        return groupedEquipments[name] ?? []
    }
    
    /// Checks if any equipment in a group is available on a specific date
    private func isAnyEquipmentAvailable(in group: [Equipment], on date: Date) -> Bool {
        return group.contains { equipment in
            equipment.isAvailable(on: date)
        }
    }
    
    /// Gets all available equipment from a group on a specific date
    private func getAvailableEquipment(from group: [Equipment], on date: Date) -> [Equipment] {
        return group.filter { equipment in
            equipment.isAvailable(on: date)
        }
    }



