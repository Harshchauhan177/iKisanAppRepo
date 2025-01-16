//
//  CreateRequestViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 16/01/25.
//

import UIKit

class CreateRequestViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var CollectionViewCategory: UICollectionView!
    
    var categories = ["Combine", "Rice", "Wheat", "Corn", "Top-rated"]

    
    override func viewDidLoad() {
        super.viewDidLoad()

        CollectionViewCategory.delegate = self
        CollectionViewCategory.dataSource = self
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath)
                if let label = cell.contentView.viewWithTag(100) as? UILabel {
                    label.text = categories[indexPath.item]
                } else {
                    let label = UILabel(frame: cell.contentView.bounds)
                    label.tag = 100
                    label.text = categories[indexPath.item]
                    label.textAlignment = .center
                    label.font = UIFont.systemFont(ofSize: 14)
                    label.textColor = .black
                    label.layer.borderColor = UIColor.lightGray.cgColor
                    label.layer.borderWidth = 1
                    label.layer.cornerRadius = 15
                    label.clipsToBounds = true
                    cell.contentView.addSubview(label)
                }

                return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: 120, height: 40)
        }

    
//    @IBAction func CalendarButtonTapped(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            if let calendarVC = storyboard.instantiateViewController(withIdentifier: "CalendarViewController") {
//                calendarVC.modalPresentationStyle = .fullScreen
//                self.present(calendarVC, animated: true, completion: nil)
//            }
//    }
    
    
}
