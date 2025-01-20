//
//  myTableViewCell.swift
//  iKisanApp
//
//  Created by harsh chauhan on 19/01/25.
//

import UIKit

class myTableViewCell: UITableViewCell,UICollectionViewDataSource,UICollectionViewDelegate  {

    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        
        self.contentView.layer.cornerRadius = 10
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.borderWidth = 3
        self.contentView.layer.borderColor = UIColor.lightGray.cgColor
        self.contentView.backgroundColor = .white

        // Add shadow for spacing effect (optional)
        self.layer.shadowColor = UIColor.gray.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowOpacity = 0.4
        self.layer.shadowRadius = 4
        self.layer.masksToBounds = false
        
    }

    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return eData[myCollectionView.tag].Equipmentsimage.count
    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = myCollectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! myCollectionViewCell
        
        cell.myEquipmentImage.image = UIImage(named: eData[myCollectionView.tag].Equipmentsimage[indexPath.row])
//        cell.myEquipmentsName.text =
        
        cell.myEquipmentImage.layer.cornerRadius = cell.myEquipmentImage.frame.size.width / 2
        cell.myEquipmentImage.layer.masksToBounds = true
                // Round corners for contentView
                contentView.layer.cornerRadius = 19
                contentView.layer.masksToBounds = true
        cell.myEquipmentImage.layer.borderWidth = 2.0
        cell.myEquipmentImage.layer.borderColor = UIColor.gray.cgColor


        
        return cell
        
    }
    
    
    

    
    
    
    
    
    
    
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        
    }

}
