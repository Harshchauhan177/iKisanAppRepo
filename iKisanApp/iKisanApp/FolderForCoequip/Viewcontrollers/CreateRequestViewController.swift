//
//  CreateRequestViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 17/01/25.
//

import UIKit

class CreateRequestViewController: UIViewController {
    
    
    @IBOutlet weak var CreateRequestCollectionVC: UICollectionView!
    
    var categories:[CropCatergory] = [.init(name: "All"),.init(name: "Wheat"),.init(name: "Rice"),.init(name: "Maize"),.init(name: "Paddy"),.init(name: "Jute"),.init(name: "Pulses"),.init(name: "Soyabean")]
    override func viewDidLoad() {
        super.viewDidLoad()
        CreateRequestCollectionVC.register(UINib(nibName: CategoryCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: CategoryCollectionViewCell.identifier)
        CreateRequestCollectionVC.delegate = self
        CreateRequestCollectionVC.dataSource = self
    }
    
}

extension CreateRequestViewController:UICollectionViewDataSource,UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CategoryCollectionViewCell.identifier, for: indexPath) as! CategoryCollectionViewCell
        cell.update(category: categories[indexPath.row])
        return cell
    }
}

