//
//  ImageViewCollectionViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 20/01/25.
//

import UIKit

private let reuseIdentifier = "Cell"

class ImageViewCollectionViewController: UICollectionViewController {

    var imageNames: [String] = []

       override func viewDidLoad() {
           super.viewDidLoad()

           print("ImageViewCollectionViewController loaded with \(imageNames.count) images: \(imageNames)")

           // Set up navigation title and close button
           title = "Equipment Images"
           
           // Add close button for modal presentation
           navigationItem.leftBarButtonItem = UIBarButtonItem(
               barButtonSystemItem: .close,
               target: self,
               action: #selector(closeButtonTapped)
           )

           // Show empty state if no images
           if imageNames.isEmpty {
               title = "No Images Available"
           }

           if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                   layout.scrollDirection = .horizontal
                   layout.itemSize = CGSize(width: view.frame.width - 8, height: view.frame.height)
                   layout.minimumLineSpacing = 0
               layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
               }
               
               collectionView.isPagingEnabled = true
       }
    
    @objc private func closeButtonTapped() {
        // Handle both modal presentation and navigation controller presentation
        if let presentingVC = presentingViewController {
            presentingVC.dismiss(animated: true, completion: nil)
        } else if let navController = navigationController {
            navController.dismiss(animated: true, completion: nil)
        }
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = imageNames.count
        print("Collection view returning \(count) items")
        return count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCollectionViewCell
        
        let imageName = imageNames[indexPath.row]
        cell.updateCellData(with: imageName)
        
        return cell
    }

}
