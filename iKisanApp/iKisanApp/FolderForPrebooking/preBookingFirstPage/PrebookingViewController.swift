//
//  PrebookingViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class PrebookingViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate, preBookingEquipmentSectionAddPreBookCollectionViewCellDelegate{
    
    
    
    
    var hasAddPreBook : Bool = true //
    var selectedIndexPath: IndexPath?
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let searchController = UISearchController()
        navigationItem.searchController = searchController
        searchController.obscuresBackgroundDuringPresentation = false
//        navigationItem.hidesSearchBarWhenScrolling = false
        
        let firstNib = UINib(nibName: "preBookingEquipmentSection1CollectionViewCell", bundle: nil)
        let secondNib = UINib(nibName: "preBookingEquipmentSection2CollectionViewCell", bundle: nil)
        let thirdNib = UINib(nibName: "preBookingEquipmentSection3CollectionViewCell", bundle: nil)
        let fourthNib = UINib(nibName: "preBookingEquipmentSection4CollectionViewCell", bundle: nil)
        let fifthNib = UINib(nibName: "preBookingEquipmentSectionAddPreBookCollectionViewCell", bundle: nil)
        collectionView.register(firstNib, forCellWithReuseIdentifier: "First")
        collectionView.register(secondNib, forCellWithReuseIdentifier: "Second")
        collectionView.register(thirdNib, forCellWithReuseIdentifier: "Third")
        collectionView.register(fourthNib, forCellWithReuseIdentifier: "Fourth")
        collectionView.register(fifthNib, forCellWithReuseIdentifier: "Fifth")

        collectionView.register(PreBookingSectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "PreBookingSectionHeader")
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        PreBookingScreenData.preBookingSectionHeaderNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            PreBookingScreenData.preBookingSection1Data.count
        case 1:
            1
        case 2:
            hasAddPreBook ? 2 : 0
//            2
        case 3:
//            PreBookingScreenData.preBookingSection3Data.count
            5
        case 4:
            3
        default:
            0
        }
    }

   
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! preBookingEquipmentSection1CollectionViewCell
            cell.updatePreBookingSection1Data(with: indexPath)
            cell.layer.cornerRadius = 7
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Second", for: indexPath) as! preBookingEquipmentSection2CollectionViewCell
            cell.layer.cornerRadius = 12
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Fifth", for: indexPath) as! preBookingEquipmentSectionAddPreBookCollectionViewCell
//            cell.updatePreBookingSection4Data(with: indexPath)
           cell.delegate = self
            cell.equipmentImageView.layer.cornerRadius = 7
            
            cell.layer.cornerRadius = 15
            return cell
            
        case 3:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Third", for: indexPath) as! preBookingEquipmentSection3CollectionViewCell
            cell.updatePreBookingSection3Data(with: indexPath)
            cell.equipmentImageView.layer.cornerRadius = 7
            cell.layer.cornerRadius = 15
            return cell
        case 4:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Fourth", for: indexPath) as! preBookingEquipmentSection4CollectionViewCell
            cell.updatePreBookingSection4Data(with: indexPath)
            cell.layer.cornerRadius = 10
            return cell
            
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! preBookingEquipmentSection1CollectionViewCell
            cell.updatePreBookingSection1Data(with: indexPath)
            cell.layer.cornerRadius = 7
            return cell
            
        }
    }
    
    
    func generateLayout()-> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, enivironment) -> NSCollectionLayoutSection? in let section: NSCollectionLayoutSection
                switch sectionIndex{
                case 0:
                    section = self.generatePreBookingSection1Layout()
                case 1:
                    section = self.generatePreBookingSection2Layout()
                case 2:
                    section = self.generatePreBookingSectionAddPreBookLayout()
                case 3:
                    section = self.generatePreBookingSection3Layout()
                case 4:
                    section = self.generatePreBookingSection4Layout()
                default:
                    print("wrong section")
                    return self.generatePreBookingSection1Layout()
                }
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
                return section
            }
        return layout
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "PreBookingSectionHeader", for: indexPath) as! PreBookingSectionHeaderCollectionReusableView
            header.headerLabel.text = PreBookingScreenData.preBookingSectionHeaderNames[indexPath.section]
            header.headerLabel.font = UIFont.systemFont(ofSize: 18,weight: .bold)
            header.button.tag = indexPath.section
//            header.button.addTarget(self, action: #selector(SectionButtonTapped(_:)), for: .touchUpInside)
            header.button.setTitle("See All", for: .normal)
            return header
        }
        print("Supplementry item not header")
        return UICollectionReusableView()
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
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .fractionalHeight(1.0))
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.01),
                    heightDimension: .absolute(377)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                group.interItemSpacing = .fixed(16)
                let section = NSCollectionLayoutSection(group: group)
                section.interGroupSpacing = 16 // Spacing between groups
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)
                return section
    }
    
    func generatePreBookingSection3Layout() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(560))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 5)
            group.interItemSpacing = .fixed(10.0)
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            return section
        }
    
    func generatePreBookingSection4Layout() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.922), heightDimension: .absolute(180))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
        group.interItemSpacing = .fixed(5.0)
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            return section
        }
    
    func generatePreBookingSectionAddPreBookLayout() -> NSCollectionLayoutSection {
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.92), heightDimension: .absolute(210))
            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 2)
            group.interItemSpacing = .fixed(10.0)
            group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            let section = NSCollectionLayoutSection(group: group)
            section.orthogonalScrollingBehavior = .groupPagingCentered
            return section
        }
    
    func userSearched(){
        hasAddPreBook = false
        collectionView.reloadData()
    }
    
    
    @IBAction func searchPreBookingButtonTapped(_ sender: Any) {
        
    //hasAddPreBook = true
//        collectionView.reloadData()
        
       userSearched()
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
           selectedIndexPath = indexPath
    //
          let selectedEquipment = EquipmentData.equipment[indexPath.row]
    //      let controller = EquipmentDescriptionTableViewController.instantiate()
    //        print("inside didselect")
            
           
            let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
          if let controller = storyboard.instantiateViewController(withIdentifier: "EquipmentDescriptionTableViewController") as? EquipmentDescriptionTableViewController {
              print("EquipmentDescriptionTableViewController")
             
              controller.equipmentName = selectedEquipment.name
            
              controller.discountedPriceHr = "₹ \(selectedEquipment.pricePerHour)/hr"
              controller.realPriceHr = "\(selectedEquipment.realPricePerHour)"
              controller.discountedPriceAc = "₹ \(selectedEquipment.pricePerAcre)/ac"
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
    
    func didTapViewButton(on cell: preBookingEquipmentSectionAddPreBookCollectionViewCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            print("View button tapped on cell at index: \(indexPath.row)")
        }
        let storyboard = UIStoryboard(name: "Tab2Prebooking", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "reviewPreBookingTableViewController") as? reviewPreBookingTableViewController {
            //viewController.modalTransitionStyle = .crossDissolve
            viewController.modalPresentationStyle = .fullScreen // Optional: Set presentation style
            //present(viewController, animated: true, completion: nil)
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    
    
    
    

}
