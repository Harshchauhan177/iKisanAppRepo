//
//  infoAboutEquipmentsViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/01/25.
//

import UIKit

class infoAboutEquipmentsViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var dataController: DataController!
    var selectedEquipmentId: UUID!
    private var sectionHeaders: [String] = []
    private var equipmentTypeDetails: [EquipmentAgri] = []
    private var relatedEquipment: [EquipmentAgri] = []
    override func viewDidLoad() {
        super.viewDidLoad()
         
        print("InfoAboutEquipments - viewDidLoad")
        print("DataController: \(dataController != nil ? "exists" : "nil")")
        print("SelectedEquipmentId: \(selectedEquipmentId?.uuidString ?? "nil")")
        
        setupCollectionView()
        setupNavigationBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            loadData()
            
            Task {
                self.equipmentTypeDetails = try! await SupabaseManager.shared.client
                    .from("equipmentAgri")
                    .select("*")
                    .eq("id", value: selectedEquipmentId)
                    .execute()
                    .value
                if self.equipmentTypeDetails.count > 0 {
                    let categoryId = self.equipmentTypeDetails[0].categoryId
                    
                    self.relatedEquipment = try! await SupabaseManager.shared.client
                        .from("equipmentAgri")
                        .select()
                        .eq("categoryId", value: categoryId)
                        .neq("id", value: selectedEquipmentId)
                        .execute()
                        .value
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
   
    
    private func setupNavigationBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "Back",
            style: .plain,
            target: self,
            action: #selector(dismissVC)
        )
    }
    
    @objc private func dismissVC() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    private func setupCollectionView() {
        // Register cell nibs
        let firstNib = UINib(nibName: "InfoAboutEquipmentDetailsCollectionViewCell", bundle: nil)
        let secondNib = UINib(nibName: "RelatedEquipmentCollectionViewCell", bundle: nil)
        
        collectionView.register(firstNib, forCellWithReuseIdentifier: "First")
        collectionView.register(secondNib, forCellWithReuseIdentifier: "Second")
        
        // Register header
        collectionView.register(
            AgriSectionHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeader"
        )
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = generateLayout()
    }
    
    private func loadData() {
        guard let equipmentId = selectedEquipmentId else {
            print("Error: selectedEquipmentId is nil")
            return
        }
        
        guard let dataController = dataController else {
            print("Error: dataController is nil")
            return
        }
        
        print("Loading info for equipment ID: \(equipmentId)")
        
        // Load section headers
        sectionHeaders = dataController.getEquipmentSectionHeaders()
        print("Loaded section headers: \(sectionHeaders)")
        
        // Load equipment details
        if let equipment = dataController.getEquipmentAgriDetails(id: equipmentId) {
            print("Found equipment: \(equipment.name)")
            equipmentTypeDetails = [equipment]
            
            // Load related equipment
            relatedEquipment = dataController.getRelatedEquipment()
                .filter { $0.id != equipmentId }
            print("Found \(relatedEquipment.count) related equipment items")
            
            DispatchQueue.main.async {
                self.collectionView.reloadData()
            }
        } else {
            print("Warning: Could not find equipment with ID: \(equipmentId)")
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        print("Number of sections: \(sectionHeaders.count)")
        return sectionHeaders.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = switch section {
        case 0:
            equipmentTypeDetails.count
        case 1:
            relatedEquipment.count
        default:
            0
        }
        print("Number of items in section \(section): \(count)")
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as? InfoAboutEquipmentDetailsCollectionViewCell,
                  let equipment = equipmentTypeDetails[safe: indexPath.item] else {
                return UICollectionViewCell()
            }
            cell.configure(with: equipment)
            cell.layer.cornerRadius = 7
//            applyShadowStyling(to: cell)
            return cell
            
        case 1:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Second", for: indexPath) as? RelatedEquipmentCollectionViewCell,
                  let equipment = relatedEquipment[safe: indexPath.item] else {
                return UICollectionViewCell()
            }
            cell.configure(with: equipment)
            cell.layer.cornerRadius = 7
//            applyShadowStyling(to: cell)
            return cell
            
        default:
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                       withReuseIdentifier: "SectionHeader",
                                                                       for: indexPath) as! AgriSectionHeaderCollectionReusableView
            header.headerLabel.text = sectionHeaders[indexPath.section]
            header.headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
            
            header.button.tag = indexPath.section
            header.button.setTitle("See All", for: .normal)
            header.button.addTarget(self, action: #selector(seeAllButtonTapped(_:)), for: .touchUpInside)
            return header
        }
        return UICollectionReusableView()
    }
    
    @objc private func seeAllButtonTapped(_ sender: UIButton) {
        let section = sender.tag
        var equipmentToShow: [EquipmentAgri] = []
        
        switch section {
        case 0:
            // For the first section, show all equipment of the same type
            if let currentEquipment = equipmentTypeDetails.first {
                equipmentToShow = dataController.getEquipmentsByCategory(categoryId: currentEquipment.categoryId)
            }
        case 1:
            // For the second section, show all related equipment
            equipmentToShow = dataController.getRelatedEquipment()
        default:
            return
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let sameTypeVC = storyboard.instantiateViewController(withIdentifier: "SameTypeAllEquipmentsViewController") as? SameTypeAllEquipmentsViewController {
            sameTypeVC.dataController = self.dataController
            sameTypeVC.equipments = equipmentToShow
            sameTypeVC.title = sectionHeaders[section]
            navigationController?.pushViewController(sameTypeVC, animated: true)
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
    
    func generateSection1Layout() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.94), heightDimension: .absolute(510))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 8.0, leading: 5.0, bottom: 8.0, trailing: 5.0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    
    func generateSection2Layout() -> NSCollectionLayoutSection {

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

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
