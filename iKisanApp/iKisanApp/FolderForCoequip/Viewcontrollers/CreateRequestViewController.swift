//
//  CreateRequestViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit

class CreateRequestViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource {
    
    
    @IBOutlet weak var CreateRequestCollectionVC: UICollectionView!
    //
    //    let categories: [EquipmentCategory] = [.harvester, .tractor, .plow, .irrigation]
    //        var equipmentList: [Equipment] = [] // Assuming equipment list is populated elsewhere
    //
    //        var currentFilter = Filter(searchText: "Harvester", category: .harvester, locationRange: 50.0, minimumRating: 4.0)
    //
    //        var filteredEquipmentList: [Equipment] {
    //            return equipmentList.filter { equipment in
    //                if let filterCategory = currentFilter.category {
    //                    return equipment.category == filterCategory
    //                }
    //                return true
    //            }
    //        }
    //
    //        override func viewDidLoad() {
    //            super.viewDidLoad()
    //
    //            let section1Nib = UINib(nibName: "Section1CollectionViewCell", bundle: nil)
    //            CreateRequestCollectionVC.register(section1Nib, forCellWithReuseIdentifier: "Section1Cell")
    //
    //            let section2Nib = UINib(nibName: "Section2CollectionViewCell", bundle: nil)
    //            CreateRequestCollectionVC.register(section2Nib, forCellWithReuseIdentifier: "Section2Cell")
    //
    //            CreateRequestCollectionVC.delegate = self
    //            CreateRequestCollectionVC.dataSource = self
    //
    //            CreateRequestCollectionVC.collectionViewLayout = generateLayout()
    //        }
    //
    //        // MARK: - UICollectionView DataSource
    //
    //        func numberOfSections(in collectionView: UICollectionView) -> Int {
    //            return 2 // Two sections: categories and filtered equipment
    //        }
    //
    //        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    //            switch section {
    //            case 0:
    //                return categories.count // Categories section
    //            case 1:
    //                return filteredEquipmentList.count // Filtered equipment section
    //            default:
    //                return 0
    //            }
    //        }
    //
    //        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    //            switch indexPath.section {
    //            case 0:
    //                // Section 1: Categories (Horizontal Scrolling)
    //                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Section1Cell", for: indexPath) as! Section1CollectionViewCell
    //                cell.updateCategoryData(with: categories[indexPath.row]) // Pass the category for updating the cell
    //                return cell
    //            case 1:
    //                // Section 2: Filtered Equipment (Vertical Scrolling)
    //                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Section2Cell", for: indexPath) as! Section2CollectionViewCell
    //                cell.updateSection2Data(with: filteredEquipmentList[indexPath.row]) // Pass the equipment for updating the cell
    //                return cell
    //            default:
    //                return UICollectionViewCell()
    //            }
    //        }
    //
    //        // MARK: - UICollectionView Delegate
    //
    //        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    //            if indexPath.section == 0 {
    //                // When a category is selected, filter the equipment list based on the selected category
    //                let selectedCategory = categories[indexPath.row]
    //                currentFilter.category = selectedCategory
    //                collectionView.reloadSections(IndexSet([1])) // Reload section 1 (Filtered Equipment)
    //            }
    //        }
    //
    //        // MARK: - Layout Generation
    //
    //        func generateLayout() -> UICollectionViewLayout {
    //            let layout = UICollectionViewCompositionalLayout { sectionIndex, environment in
    //                var section: NSCollectionLayoutSection
    //                switch sectionIndex {
    //                case 0:
    //                    section = self.generateCategorySection1Layout() // Horizontal Scrolling for Category Section
    //                case 1:
    //                    section = self.generateEquipmentSection2Layout() // Vertical Scrolling for Equipment Section
    //                default:
    //                    section = self.generateCategorySection1Layout() // Default Layout for Categories
    //                }
    //                return section
    //            }
    //            return layout
    //        }
    //
    //        // MARK: - Category Section (Horizontal Scrolling)
    //
    //        func generateCategorySection1Layout() -> NSCollectionLayoutSection {
    //            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(1.0))
    //            let item = NSCollectionLayoutItem(layoutSize: itemSize)
    //
    //            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
    //            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    //
    //            let section = NSCollectionLayoutSection(group: group)
    //            section.orthogonalScrollingBehavior = .continuous // Horizontal scrolling behavior
    //            return section
    //        }
    //
    //        // MARK: - Equipment Section (Vertical Scrolling)
    //
    //        func generateEquipmentSection2Layout() -> NSCollectionLayoutSection {
    //            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
    //            let item = NSCollectionLayoutItem(layoutSize: itemSize)
    //
    //            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(150))
    //            let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 1)
    //
    //            let section = NSCollectionLayoutSection(group: group)
    //            section.interGroupSpacing = 10 // Add space between items vertically
    //            return section
    //        }
    //    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let firstNib = UINib(nibName: "Section1CollectionViewCell", bundle: nil)
        let secondNib = UINib(nibName: "Section2CollectionViewCell", bundle: nil)
        
        
        CreateRequestCollectionVC.register(firstNib, forCellWithReuseIdentifier: "First")
        CreateRequestCollectionVC.register(secondNib, forCellWithReuseIdentifier: "Second")
        
        
//        CreateRequestCollectionVC.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
//
        
        
        CreateRequestCollectionVC.setCollectionViewLayout(generateLayout(), animated: true)
        
        CreateRequestCollectionVC.dataSource = self
        CreateRequestCollectionVC.delegate = self
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return EquipmentScreenData.sectionHeaders.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
            case 0:
                return EquipmentScreenData.equipmentImages.count
            case 1:
                return EquipmentScreenData.equipmentNames.count
            case 2:
                return EquipmentScreenData.equipmentDetails.count
            default:
                return 0
            }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! Section1CollectionViewCell
            cell.updateSection1Data(with: indexPath)
            cell.layer.cornerRadius = 7
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Second", for: indexPath) as! Section2CollectionViewCell
            cell.updateSection2Data(with: indexPath)
            cell.layer.cornerRadius = 7
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! Section1CollectionViewCell
            cell.updateSection1Data(with: indexPath)
            cell.layer.cornerRadius = 7
            return cell
            
        }
    }
    


    
    func generateLayout()-> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout {
            (sectionIndex, enivironment) -> NSCollectionLayoutSection? in let section: NSCollectionLayoutSection
                switch sectionIndex{
                case 0:
                    section = self.generateSection1Layout()
                case 1:
                    section = self.generateSection2Layout()
                
                default:
                    print("wrong section")
                    return self.generateSection1Layout()
                }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            section.boundarySupplementaryItems = [header]
                return section
            }
        return layout
    }
    
//    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//        if kind == UICollectionView.elementKindSectionHeader {
//            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderCollectionReusableView
//            header.headerLabel.text = EquipmentScreenData.sectionHeaders[indexPath.section]
//            header.headerLabel.font = UIFont.systemFont(ofSize: 18,weight: .bold)
//            
//            header.button.tag = indexPath.section
//            header.button.addTarget(self, action: #selector(SectionButtonTapped(_:)), for: .touchUpInside)
//            header.button.setTitle("See All", for: .normal)
    //        return header
//        }
//        print("Supplementry item not header")
//        return UICollectionReusableView()
//    }
    
    
    func generateSection1Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(300))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 0.0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    
    func generateSection2Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(0.33))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(300))
        
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitem: item, count: 3)
        
        group.interItemSpacing = .fixed(8.0)
        
        group.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 8.0, bottom: 8.0, trailing: 0.0)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.orthogonalScrollingBehavior = .groupPagingCentered
        
        return section
    }
    
   
    
    @objc func SectionButtonTapped(_ sender: UIButton){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        
    }

    


}


//#Preview{
//    var StoryBoard = UIStoryboard(name: "Main", bundle: nil)
//    var VC = StoryBoard.instantiateViewController(withIdentifier: "VC")
//    return VC
//}

