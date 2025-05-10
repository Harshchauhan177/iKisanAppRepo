//
//  HomeViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UpcomingBookingsCollectionViewCellDelegate, ExploreMoreCollectionViewCellDelegate, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, UISearchResultsUpdating {
   
    
//    var dataController: DataController = IKisanDataController()
    var dataController: DataController!
    private var allEquipment: [Equipment] = []
    private var suggestions: [Equipment] = []
    private var reviews: [ReviewData] = []
    var upcomingBookings: [Booking] = []
    var selectedSuggestion: String?
    
    var searchBar: UISearchBar!
    var tableView: UITableView!

    let requestManager = RequestManager.shared
    var dataList: [String] = []
    var filteredData: [String] = []
    
    var hasUpcomingBookings: Bool = false
    
    @IBOutlet var collectionView: UICollectionView!
    
    var selectedIndexPath: IndexPath?
    
    // Add a computed property to track number of sections
    private var numberOfSections: Int {
        // Force the upcoming bookings section to be present when hasUpcomingBookings is true
        return hasUpcomingBookings ? 4 : 3 // Return 4 sections if there are bookings, 3 if not
    }
    
    // Add a function to map visual section to data section
    private func getDataSection(for visualSection: Int) -> Int {
        if hasUpcomingBookings {
            // If we have upcoming bookings, return the section as-is
            return visualSection
        } else {
            // If no upcoming bookings, skip section 1 (which would be the bookings section)
            return visualSection >= 1 ? visualSection + 1 : visualSection
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // First check if dataController is initialized
        guard let dataController = dataController else {
            print("Error: DataController not initialized")
            // Show error alert to user
            let alert = UIAlertController(
                title: "Error",
                message: "Unable to initialize app data. Please try again later.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        collectionView.isHidden = false
        setupSearchController()
        setupTableView()

        // Add profile button to navigation bar
        let profileButton = UIBarButtonItem(
            image: UIImage(systemName: "person.circle"),
            style: .plain,
            target: self,
            action: #selector(profileButtonTapped)
        )
        navigationItem.rightBarButtonItem = profileButton
        
        // Set the collection view reference in the data controller if it's the right type
        if let ikisanDataController = dataController as? IKisanDataController {
            ikisanDataController.collectionView = self.collectionView
        }
        
        // Load data asynchronously
        loadData()
        
        // Register for booking added notifications
        NotificationCenter.default.addObserver(
            self, 
            selector: #selector(handleBookingAdded(_:)),
            name: .bookingAdded,
            object: nil
        )
        
        // Registering Nibs for cells
        let discountsNib = UINib(nibName: "DiscountsCell", bundle: nil)
        let upcomingBookingsNib = UINib(nibName: "UpcomingBookingsCollectionViewCell", bundle: nil)
        collectionView.register(upcomingBookingsNib, forCellWithReuseIdentifier: "UpcomingBookingsCollectionViewCell")
        let suggestionNib = UINib(nibName: "SuggestionCell", bundle: nil)
        let exploreMoreNib = UINib(nibName: "ExploreMoreCell", bundle: nil)
        
        collectionView.register(discountsNib, forCellWithReuseIdentifier: "DiscountsCell")
        collectionView.register(suggestionNib, forCellWithReuseIdentifier: "SuggestionCell")
        collectionView.register(exploreMoreNib, forCellWithReuseIdentifier: "ExploreMoreCell")
        
        // Registering Header View
        collectionView.register(
            SectionHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeader"
        )

        // Setting collectionView layout
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)

        // Set data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
        
        // Perform a second data load after a short delay to catch any bookings that might not be loaded initially
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Task {
                await self.loadDataFromBackend(forceRefresh: true)
                
                // Force section refresh if we have bookings, but DO NOT auto-scroll
                if !self.upcomingBookings.isEmpty {
                    self.hasUpcomingBookings = true
                    self.collectionView.reloadData()
                    
                    // Update layout without scrolling to upcoming bookings section
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        if self.collectionView.numberOfSections > 1 {
                            // Force layout update but don't scroll - auto-scrolling removed intentionally
                            self.collectionView.collectionViewLayout.invalidateLayout()
                            self.collectionView.layoutIfNeeded()
                            print("Initial setup - upcoming bookings section refreshed (no auto-scroll)")
                        }
                    }
                }
            }
        }
    }
    
    private func loadDataFromBackend(forceRefresh: Bool = false) async {
        // Fetch equipment data from backend
        allEquipment = await requestManager.fetchEquipments()
        
        // Generate the search suggestions list
        dataList = Array(Set(allEquipment.map { $0.name }))
        
        // Get suggestions and reviews
        suggestions = allEquipment.filter { $0.isRecommended }
        reviews = await requestManager.fetchReviews()
        
        // Get upcoming bookings - with force refresh
        print("Explicitly fetching bookings with forceRefresh=\(forceRefresh)")
        let allBookings = await requestManager.fetchBookings()
        
        // Debug: Print all bookings with their dates to see what's actually coming from backend
        print("All Bookings from backend:")
        for (index, booking) in allBookings.enumerated() {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .short
            let dateString = formatter.string(from: booking.bookingDate)
            print("Booking \(index + 1): ID=\(booking.bookingID), Date=\(dateString), Equipment=\(booking.equipmentID.uuidString)")
        }
        
        // IMPORTANT: Force all bookings to be shown in upcoming section
        // For now, let's show all bookings regardless of date
        upcomingBookings = allBookings
        
        // Debug information
        print("Loaded \(upcomingBookings.count) upcoming bookings")
        if !upcomingBookings.isEmpty {
            for (index, booking) in upcomingBookings.enumerated() {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.timeStyle = .short
                let dateString = formatter.string(from: booking.bookingDate)
                print("Upcoming Booking \(index + 1): Date=\(dateString), Equipment=\(booking.equipmentID.uuidString)")
            }
        }
        
        // Explicitly set hasUpcomingBookings based on booking count
        hasUpcomingBookings = !upcomingBookings.isEmpty
        print("Setting hasUpcomingBookings to \(hasUpcomingBookings)")
        
        // Print debug info
        print("Loaded equipment count: \(allEquipment.count)")
        print("Loaded suggestions count: \(suggestions.count)")
        print("Loaded reviews count: \(reviews.count)")
        print("Loaded upcoming bookings count: \(upcomingBookings.count)")
        
        // Update UI on the main thread
        await MainActor.run {
            // Force a layout update
            self.collectionView.reloadData()
            
            // Force section visibility but don't scroll
            if hasUpcomingBookings {
                // Force section visibility
                let sections = numberOfSections
                print("Number of sections: \(sections)")
                
                // No scrolling to avoid disrupting user's view
            }
        }
    }
    
    func loadData() {
        Task {
            await loadDataFromBackend(forceRefresh: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data when view appears
        loadData()
    }
    
    //MARK: Search Bar Implementation
    
    func setupSearchController() {
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Equipments"
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func setupTableView() {
            tableView = UITableView(frame: view.bounds, style: .plain)
            tableView.delegate = self
            tableView.dataSource = self
            tableView.isHidden = true
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            tableView.backgroundColor = .init(red: 0.9216, green: 0.9216, blue: 0.9216, alpha: 1.0)/*.init(red: 0.6667, green: 0.6667, blue: 0.5882, alpha: 1.0)*/
        
            view.addSubview(tableView)
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filteredData[indexPath.row]
        cell.backgroundColor = .init(red: 0.9216, green: 0.9216, blue: 0.9216, alpha: 1.0)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//    navigationItem.searchController?.searchBar.text = filteredData[indexPath.row]
//    tableView.isHidden = true
//    navigationItem.searchController?.searchBar.resignFirstResponder()

        selectedSuggestion = filteredData[indexPath.row]

        if let navController = self.navigationController {
            // Check if CreateRequestViewController already exists in the navigation stack
            if let existingVC = navController.viewControllers.first(where: { $0 is CreateRequestViewController }) as? CreateRequestViewController {
                existingVC.selectedSuggestion = selectedSuggestion
                existingVC.dataController = self.dataController
                existingVC.applySearchFilter()
                navController.popToViewController(existingVC, animated: true)
                return
            }
            
            // If CreateRequestViewController is not in the stack, create a new one
            let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
            if let createRequestVC = storyboard.instantiateViewController(withIdentifier: "CreateRequestViewController") as? CreateRequestViewController {
                createRequestVC.dataController = self.dataController
                createRequestVC.selectedSuggestion = self.selectedSuggestion
                navigationController?.pushViewController(createRequestVC, animated: true)
            }
        }

        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
   
    
    //Search Bar Functions
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            filteredData = dataList.filter { $0.lowercased().contains(searchText.lowercased()) }
            tableView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text, !searchText.isEmpty else {
                    tableView.isHidden = true
                    return
                }
                
                tableView.isHidden = false
                filteredData = dataList.filter { $0.lowercased().contains(searchText.lowercased()) }
                tableView.reloadData()
            }
    
    //MARK: Collection View Implementation
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataSection = getDataSection(for: section)
        switch dataSection {
        case 0:
            return allEquipment.count
        case 1:
            return min(upcomingBookings.count, 3) // Limit to 3 bookings in the list
        case 2:
            return suggestions.count
        case 3:
            return allEquipment.count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dataSection = getDataSection(for: indexPath.section)
        switch dataSection {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscountsCell", for: indexPath) as! DiscountsCollectionViewCell
            cell.layer.cornerRadius = 10
            //applyShadowStyling(to: cell)
            let equipment = allEquipment[indexPath.row]
            cell.updateDiscountsData(with: equipment)
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpcomingBookingsCollectionViewCell", for: indexPath) as! UpcomingBookingsCollectionViewCell
            cell.layer.cornerRadius = 13
            cell.delegate = self
            
            let booking = upcomingBookings[indexPath.row]
            print("Setting up cell for booking: \(booking.bookingID) on date: \(booking.bookingDate)")
            
            // First try exact ID match
            if let equipment = allEquipment.first(where: { equip in 
                equip.equipmentID.uuidString.lowercased() == booking.equipmentID.uuidString.lowercased() 
            }) {
                print("Found matching equipment: \(equipment.name)")
                cell.updateUpcomingBookingsData(with: booking, equipment: equipment)
            } 
            // If exact match fails, try to get equipment by ID from dataController
            else if let matchingEquipment = dataController.getEquipment(byId: booking.equipmentID) {
                print("Found equipment using dataController: \(matchingEquipment.name)")
                cell.updateUpcomingBookingsData(with: booking, equipment: matchingEquipment)
            }
            // Last resort, use first equipment as fallback - ensures something displays
            else if !allEquipment.isEmpty {
                let fallbackEquipment = allEquipment[0]
                print("WARNING: Using fallback equipment: \(fallbackEquipment.name)")
                cell.updateUpcomingBookingsData(with: booking, equipment: fallbackEquipment)
            }
            else {
                print("ERROR: Cannot find any equipment for booking: \(booking.bookingID)")
            }
            return cell
           
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCell", for: indexPath) as! SuggestionCollectionViewCell
            cell.layer.cornerRadius = 13
            //applyShadowStyling(to: cell)
            let suggestion = suggestions[indexPath.row]
            cell.updateSuggestionData(with: suggestion)
            return cell
           
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreMoreCell", for: indexPath) as! ExploreMoreCollectionViewCell
            cell.layer.cornerRadius = 13
            //applyShadowStyling(to: cell)
            let equipment = allEquipment[indexPath.row]
            cell.updateExploreMoreData(with: equipment)
            return cell

        default:
            return UICollectionViewCell()
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let dataSection = self.getDataSection(for: sectionIndex)
            let section: NSCollectionLayoutSection
            
            switch dataSection {
            case 0:
                section = self.generateDiscountSection()
            case 1:
                section = self.generateUpcomingBookingsSection()
            case 2:
                section = self.generateSuggestionSection()
            case 3:
                section = self.generateExploreMoreSection()
            default:
                section = self.generateDiscountSection()
            }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .topLeading
            )
            
            // Add consistent insets to header
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            
            section.boundarySupplementaryItems = [header]
            return section
        }
        return layout
    }


    
    func generateDiscountSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(130), heightDimension: .absolute(116))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        // Add 8-point spacing between items (same as suggestions)
        group.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 8)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 8)
        
        // Use continuousGroupLeadingBoundary for smoother scrolling
        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary
        
        return section
    }
    
    func generateUpcomingBookingsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(115))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    

    func generateSuggestionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
       group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 8)
        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    func generateExploreMoreSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(16)
       
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16 // Spacing between groups
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        return section
    }


    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderCollectionReusableView
            
            let dataSection = getDataSection(for: indexPath.section)
            
            print("Setting up header for section \(indexPath.section), dataSection: \(dataSection)")
            
            switch dataSection {
            case 0:
                header.headerLabel.text = "Discounts"
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                header.button.isHidden = true
            case 1:
                header.headerLabel.text = "Upcoming Bookings"
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                header.button.setTitle("View All", for: .normal)
                header.button.isHidden = false
                header.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
                
                // Debug - print the current upcoming bookings count
                print("Upcoming Bookings section header shown. Current bookings count: \(upcomingBookings.count)")
            case 2:
                header.headerLabel.text = "   Suggestion"
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                header.button.isHidden = true
            case 3:
                header.headerLabel.text = "Explore More"
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                header.button.isHidden = true
            default:
                header.headerLabel.text = ""
                header.button.isHidden = true
            }
            return header
        }
        return UICollectionReusableView()
    }
    
   // MARK: Extension data
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        let dataSection = getDataSection(for: indexPath.section)
        var selectedEquipment: Equipment
        
        switch dataSection {
        case 0:
            // Discounts section
            if indexPath.row < allEquipment.count {
                selectedEquipment = allEquipment[indexPath.row]
            } else {
                print("Error: Index out of range in Discounts section")
                return
            }
        case 2:
            // Suggestions section
            if indexPath.row < suggestions.count {
                selectedEquipment = suggestions[indexPath.row]
            } else {
                print("Error: Index out of range in Suggestions section")
                return
            }
        case 3:
            // Explore More section
            if indexPath.row < allEquipment.count {
                selectedEquipment = allEquipment[indexPath.row]
            } else {
                print("Error: Index out of range in Explore More section")
                return
            }
        default:
            print("Selected item in section that doesn't navigate to details")
            return
        }
        
        print("HomeViewController - Selected equipment: \(selectedEquipment.name)")
        print("HomeViewController - Selected equipment ID: \(selectedEquipment.equipmentID.uuidString.lowercased())")
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
            controller.equipment = selectedEquipment
            controller.bookingSource = .home
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    func userDidMakeBooking() {
        hasUpcomingBookings = true
        collectionView.reloadData()
    }
    
    @objc func sectionButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "UpcomingBookingsListViewController") as? UpcomingBookingsListViewController {
            // Pass the data controller and data
            viewController.dataController = self.dataController
            
            // Instead of passing local copies, let the ViewController fetch fresh data
            // Print debug info
            print("HomeViewController - Passing dataController to UpcomingBookingsListViewController")
            print("HomeViewController - Current upcomingBookings count: \(upcomingBookings.count)")
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
    }
    
    func didTapViewButton(on cell: UpcomingBookingsCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let booking = upcomingBookings[indexPath.row]
            
            // More robust equipment finding logic
            var equipmentToUse: Equipment?
            
            // First try exact ID match (case-insensitive)
            if let equipment = allEquipment.first(where: { equip in 
                equip.equipmentID.uuidString.lowercased() == booking.equipmentID.uuidString.lowercased() 
            }) {
                print("Found matching equipment: \(equipment.name)")
                equipmentToUse = equipment
            } 
            // If exact match fails, try to get equipment by ID from dataController
            else if let matchingEquipment = dataController.getEquipment(byId: booking.equipmentID) {
                print("Found equipment using dataController: \(matchingEquipment.name)")
                equipmentToUse = matchingEquipment
            }
            // Last resort, use first equipment as fallback if needed
            else if !allEquipment.isEmpty {
                let fallbackEquipment = allEquipment[0]
                print("WARNING: Using fallback equipment in didTapViewButton")
                equipmentToUse = fallbackEquipment
            }
            
            guard let equipment = equipmentToUse else {
                print("ERROR: Cannot find any equipment for booking: \(booking.bookingID)")
                return
            }
            
            // Create BookingDetailsViewController programmatically instead of from storyboard
            let viewController = BookingDetailsViewController(equipment: equipment, booking: booking)
            viewController.modalPresentationStyle = .fullScreen
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    func didTapViewButton(on cell: ExploreMoreCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
        }
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ReviewBookingTableViewController") as? ReviewBookingTableViewController {
            //viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .fullScreen // Optional: Set presentation style
            //present(viewController, animated: true, completion: nil)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
//    private func applyShadowStyling(to cell: UICollectionViewCell) {
//        // Create a shadow layer
//        cell.layer.shadowColor = UIColor.black.cgColor
//        cell.layer.shadowOpacity = 0.2
//        cell.layer.shadowRadius = 5
//        cell.layer.shadowOffset = CGSize(width: 0, height: 3)
////        cell.layer.shadowColor = UIColor.black.cgColor
////        cell.layer.shadowOffset = CGSize(width: 0, height: 2)
////        cell.layer.shadowRadius = 4
////        cell.layer.shadowOpacity = 1
//        cell.layer.masksToBounds = false
//        
//        // Make sure the content view keeps the corner radius
//        cell.contentView.layer.cornerRadius = cell.layer.cornerRadius
//        cell.contentView.layer.masksToBounds = true
//        
//        // Make sure the background is not transparent
//        cell.backgroundColor = .clear
//        cell.contentView.backgroundColor = .white
//        
//        // Improve shadow performance by setting its path
//        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.layer.cornerRadius).cgPath
//    }

    @objc private func handleBookingAdded(_ notification: Notification) {
        print("HomeViewController - Received bookingAdded notification")
        
        // Force reload all data from backend to ensure we get fresh data
        Task {
            // Small delay to ensure database updates have been completed
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 second delay
            
            // Get fresh data with force refresh
            await loadDataFromBackend(forceRefresh: true)
            
            // Update UI on main thread
            await MainActor.run {
                print("After refresh - Upcoming bookings count: \(self.upcomingBookings.count)")
                
                // Force the upcoming bookings section to be visible
                self.hasUpcomingBookings = !self.upcomingBookings.isEmpty
                if !self.upcomingBookings.isEmpty {
                    print("Force showing upcoming bookings section")
                }
                
                // Completely recreate the layout
                self.collectionView.setCollectionViewLayout(self.generateLayout(), animated: false)
                
                // Reload data and force a layout pass
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
                
                // Force a layout refresh after a delay, but don't scroll
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    // Force the layout to update again
                    self.collectionView.collectionViewLayout.invalidateLayout()
                    self.collectionView.layoutIfNeeded()
                    
                    print("Layout refreshed with \(self.collectionView.numberOfSections) sections visible")
                }
            }
        }
    }

    @objc private func profileButtonTapped() {
        // Use the SwiftUI ProfileView wrapped in a UIHostingController
        let profileVC = ProfileHostingController()
        navigationController?.pushViewController(profileVC, animated: true)
    }

    deinit {
        // Remove notification observer when this view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Make sure our collection view layout matches our data state
        if collectionView.numberOfSections != numberOfSections {
            collectionView.collectionViewLayout.invalidateLayout()
            collectionView.reloadData()
        }
    }
}
