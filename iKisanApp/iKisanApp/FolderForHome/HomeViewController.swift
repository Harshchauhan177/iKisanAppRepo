//
//  HomeViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UpcomingBookingsCollectionViewCellDelegate, ExploreMoreCollectionViewCellDelegate {
   
    
   
    
    
    var hasUpcomingBookings: Bool = false
    
    @IBOutlet var collectionView: UICollectionView!
    
    var selectedIndexPath: IndexPath?
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        
        let searchController = UISearchController()
        navigationItem.searchController = searchController

        searchController.obscuresBackgroundDuringPresentation = false
        
        //searchController.
        //searchController.searchResultsUpdater = self

        navigationItem.hidesSearchBarWhenScrolling = false

        
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
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
       
        return 4
        //hasUpcomingBookings ? 4 : 3
        //return 3 // Discounts, Suggestion, Explore More
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            //return 3
            return 6
            // Example: Discounts data count
        case 1:
            return hasUpcomingBookings ? 3 : 0
            //return 3 // Example: Suggestion has 3 cards
        case 2:
            return  EquipmentData.suggestionsEquipment.count// 4// Number of Explore More items
            //return 4// Example: Explore More data count
            
            //for additional view
        case 3:
            return 4
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscountsCell", for: indexPath) as! DiscountsCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.updateDiscountsData(with: indexPath)
            return cell
            
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UpcomingBookingsCollectionViewCell", for: indexPath) as! UpcomingBookingsCollectionViewCell
                    cell.layer.cornerRadius = 13
            cell.delegate = self
                    cell.updateUpcomingBookingsData(with: indexPath)
                    return cell
           
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCell", for: indexPath) as! SuggestionCollectionViewCell
            cell.layer.cornerRadius = 13
            cell.updateSuggestionData(with: indexPath)
            return cell
           
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreMoreCell", for: indexPath) as! ExploreMoreCollectionViewCell
            cell.layer.cornerRadius = 13
            cell.updateExploreMoreData(with: indexPath)
            return cell
           

        default:
            return UICollectionViewCell()
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section: NSCollectionLayoutSection
            
            switch sectionIndex {
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
//            case 1:
//                section = self.generateSuggestionSection()
//            case 2:
//                section = self.generateExploreMoreSection()
//            default:
//                section = self.generateDiscountSection()
            }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
        return layout
    }

    func generateDiscountSection() -> NSCollectionLayoutSection {
      // let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(150))
       
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(130), heightDimension: .absolute(116))
      //let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(116))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }
    func generateUpcomingBookingsSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(115))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    

    func generateSuggestionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
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
            switch indexPath.section {
            case 0:
                header.headerLabel.text = "Discounts"
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            case 1:
                header.headerLabel.text =  hasUpcomingBookings ? "Upcoming Bookings" : ""
                header.button.setTitle(hasUpcomingBookings ? "View All" : "", for: .normal)
                header.button.addTarget(self, action: #selector(sectionButtonTapped(_:)), for: .touchUpInside)
                //"Upcoming Bookings"
                
//                header.headerLabel.text = "Suggestion"
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
                
            case 2:
                header.headerLabel.text = "Suggestion"
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            case 3:
                header.headerLabel.text = "Explore More"
                header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            default:
                break
            }
            return header
        }
        return UICollectionReusableView()
    }
    
   // MARK: Extension data
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        
        let selectedEquipment = EquipmentData.equipment[indexPath.row]
//        let controller = EquipmentDescriptionTableViewController.instantiate()
        print("inside didselect")
        
       
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
      if let controller = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
          print("EquipmentDescriptionTableViewController")
         
          controller.equipmentName = selectedEquipment.name
        
          controller.discountedPriceHr = "\(selectedEquipment.pricePerHour)"
          controller.realPriceHr = "\(selectedEquipment.realPricePerHour)"
          controller.discountedPriceAc = "\(selectedEquipment.pricePerAcre)"
          controller.realPriceAc = "\(selectedEquipment.realPricePerAcre)"
          controller.coEquipDetail = "\(selectedEquipment.coEquipDetail) For CoEquip"
          controller.location = "\(selectedEquipment.location)"
          controller.rating = "\(selectedEquipment.rating)"
          controller.bigImage = "\(selectedEquipment.equipmentImage)"//equipmentMoreImages.images[0])"
          controller.smallImage1 = "\(selectedEquipment.equipmentImage)"//.equipmentMoreImages.images[1])"
          controller.smallImage2 = "\(selectedEquipment.equipmentImage)"//.equipmentMoreImages.images[2])"
          controller.smallImage3 = "\(selectedEquipment.equipmentImage)"//.equipmentMoreImages.images[3])"
          controller.more = "\(selectedEquipment.equipmentMoreImages.images.count)"
          controller.ratingOutOf5 = "\(selectedEquipment.rating)"
          controller.equipmentLocationDetailed = "\(selectedEquipment.location)"
          controller.model = "\(selectedEquipment.modelYear)"
          controller.capacity = "\(selectedEquipment.capacity)"
          controller.mileage = "\(selectedEquipment.mielage)"
          controller.moreImages = selectedEquipment.equipmentMoreImages.images

          navigationController?.pushViewController(controller, animated: true)
        }
       
    }
    func userDidMakeBooking() {
        hasUpcomingBookings = true
        collectionView.reloadData()
    }
    
    @objc func sectionButtonTapped( _ sender: UIButton){
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "UpcomingBookingsListViewController") as!
        UpcomingBookingsListViewController
        //viewController.sectionNumber = sender.tag
       navigationController?.pushViewController(viewController, animated: true)
    }
    override func unwind(for unwindSegue: UIStoryboardSegue, towards subsequentVC: UIViewController) {
        
    }
    
    func didTapViewButton(on cell: UpcomingBookingsCollectionViewCell) {
        // Get the indexPath of the cell
        if let indexPath = collectionView.indexPath(for: cell) {
            print("View button tapped on cell at index: \(indexPath.row)")
        }
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "BookingDetailsViewController") as? BookingDetailsViewController {
            //viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .fullScreen // Optional: Set presentation style
            //present(viewController, animated: true, completion: nil)
            navigationController?.pushViewController(viewController, animated: true)
        }
        
    }
    func didTapViewButton(on cell: ExploreMoreCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            print("View button tapped on cell at index: \(indexPath.row)")
        }
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "ReviewBookingTableViewController") as? ReviewBookingTableViewController {
            //viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .fullScreen // Optional: Set presentation style
            //present(viewController, animated: true, completion: nil)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
}
