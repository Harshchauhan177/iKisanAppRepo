//
//  myTableViewCell.swift
//  iKisanApp
//
//  Created by harsh chauhan on 19/01/25.
//

import UIKit

protocol MyTableViewCellDelegate: AnyObject {
    func didTapSeeAll(for category: EquipmentCategory)
}

class myTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate  {
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    @IBOutlet weak var EquipmentTypeLabel: UILabel!
    @IBOutlet weak var viewAllButton: UIButton!
    
    var dataController: DataController!
    var selectedCropId: UUID!
    var sectionIndex: Int = 0
    private var equipmentCategory: EquipmentCategory?
    weak var delegate: MyTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        setupUI()
        myCollectionView.showsHorizontalScrollIndicator = false
        myCollectionView.showsVerticalScrollIndicator = false
    }
    
    private func setupUI() {
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.borderWidth = 3
        self.contentView.layer.borderColor = .init(red: 0.9216, green: 0.9216, blue: 0.9216, alpha: 1.0)
        self.contentView.backgroundColor = .white
        // Add shadow for spacing effect
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
    }
    
    func configure(with category: EquipmentCategory) {
        print("Configuring cell with category: \(category.title)")
        print("Equipment count: \(category.equipmentList.count)")
        self.equipmentCategory = category
        EquipmentTypeLabel.text = category.title
        myCollectionView.reloadData()
    }
    
    @IBAction func seeAllButtonTapped(_ sender: UIButton) {
        if let category = equipmentCategory {
            delegate?.didTapSeeAll(for: category)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = equipmentCategory?.equipmentList.count ?? 0
        print("Number of items in collection view: \(count)")
        return count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? myCollectionViewCell,
              let equipment = equipmentCategory?.equipmentList[indexPath.item] else {
            print("Failed to dequeue cell or get equipment")
            return UICollectionViewCell()
        }
        
        print("Configuring cell for equipment: \(equipment.name)")
        cell.configure(with: equipment)
        
        return cell
    }
  
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let equipment = equipmentCategory?.equipmentList[indexPath.item],
              let viewController = parentViewController as? EquipmentsForCropsViewController else {
            print("Failed to get equipment or view controller")
            return
        }
        
        print("Selected equipment in collection view: \(equipment.name) with ID: \(equipment.id)")
        collectionView.deselectItem(at: indexPath, animated: true)
        viewController.performSegue(withIdentifier: "ShowEquipmentDetails", sender: equipment)
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }
}
