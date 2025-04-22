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

    let dataList =  Array(Set(EquipmentData.equipment.map { $0.name })) //(for distinct values) //EquipmentData.equipment.map { $0.name }
    var filteredData: [String] = []
    
    var hasUpcomingBookings: Bool = false
    
    @IBOutlet var collectionView: UICollectionView!
    
    var selectedIndexPath: IndexPath?
    
    // Add a computed property to track number of sections
    private var numberOfSections: Int {
        return hasUpcomingBookings ? 4 : 3 // Return 4 sections if there are bookings, 3 if not
    }
    
    // Add a function to map visual section to data section
    private func getDataSection(for visualSection: Int) -> Int {
        if !hasUpcomingBookings && visualSection >= 1 {
            // If no upcoming bookings, shift sections up by 1
            return visualSection + 1
        }
        return visualSection
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.isHidden = false
        setupSearchController()
        setupTableView()

        //Data from Data Controller
        guard let dataController = dataController else {
            print("Error: DataController not initialized")
            return
        }
        
        Task {
            allEquipment = await RequestManager.shared.fetchEquipments()
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        }
        
        // Load data and refresh suggestions
        loadData()
        
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
    }
    
    private func loadData() {
        allEquipment = dataController.getAllEquipment()
        suggestions = dataController.getSuggestions()  // This will now use persisted crop selections
        reviews = dataController.getAllReviews()
        upcomingBookings = dataController.getUpcomingBookings()
        
        // Update hasUpcomingBookings based on actual bookings
        hasUpcomingBookings = !upcomingBookings.isEmpty
        
        // Print debug info
        print("Loaded suggestions count: \(suggestions.count)")
        print("Selected crops: \(dataController.getSelectedCrops())")
        
        // Refresh UI
        collectionView.reloadData()
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
            return min(upcomingBookings.count, 3)
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
           // applyShadowStyling(to: cell)
            cell.delegate = self
            
            let booking = upcomingBookings[indexPath.row]
            if let equipment = allEquipment.first(where: { $0.equipmentID == booking.equipmentID }) {
                cell.updateUpcomingBookingsData(with: booking, equipment: equipment)
            }
            return cell
           
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCell", for: indexPath) as! SuggestionCollectionViewCell
            cell.layer.cornerRadius = 13
          //  applyShadowStyling(to: cell)
            let suggestion = suggestions[indexPath.row]
            cell.updateSuggestionData(with: suggestion)
            return cell
           
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreMoreCell", for: indexPath) as! ExploreMoreCollectionViewCell
            cell.layer.cornerRadius = 13
           // applyShadowStyling(to: cell)
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
        
        let selectedEquipment = EquipmentData.equipment[indexPath.row]
        print("HomeViewController - Selected equipment: \(selectedEquipment.name)")
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
            controller.equipment = selectedEquipment
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
            viewController.upcomingBookings = self.upcomingBookings
            viewController.allEquipment = self.allEquipment
            
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
    }
    
    func didTapViewButton(on cell: UpcomingBookingsCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            let booking = upcomingBookings[indexPath.row]
            if let equipment = allEquipment.first(where: { $0.equipmentID == booking.equipmentID }) {
                let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
                if let viewController = storyboard.instantiateViewController(withIdentifier: "BookingDetailsViewController") as? BookingDetailsViewController {
                    viewController.modalPresentationStyle = .fullScreen
                    viewController.equipment = equipment
                    viewController.booking = booking
                    navigationController?.pushViewController(viewController, animated: true)
                }
            }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh the bookings data when the view appears
        if let dataController = dataController {
            upcomingBookings = dataController.getUpcomingBookings()
            hasUpcomingBookings = !upcomingBookings.isEmpty
            collectionView.reloadData()
        }
        
        // Refresh suggestions based on selected crop
        suggestions = dataController.getSuggestions()
        collectionView.reloadData()
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
}
