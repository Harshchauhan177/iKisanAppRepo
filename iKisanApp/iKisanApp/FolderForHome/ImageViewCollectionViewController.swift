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

           if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
                   layout.scrollDirection = .horizontal
                   layout.itemSize = CGSize(width: view.frame.width - 8, height: view.frame.height)
                   layout.minimumLineSpacing = 0
               layout.sectionInset = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
               }
               
               collectionView.isPagingEnabled = true
       }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCollectionViewCell
        
        // Safely unwrap the imageView outlet to prevent crashes
        if let imageView = cell.imageView {
            let imageName = imageNames[indexPath.row]
            
            // Check if image name is a URL
            if imageName.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imageView.loadImage(from: imageName)
            } else {
                // Local asset
                imageView.image = UIImage(named: imageName) ?? UIImage(named: "placeholder_image")
            }
        }
        
        return cell
    }

}
