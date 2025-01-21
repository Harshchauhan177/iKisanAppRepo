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
                   layout.itemSize = CGSize(width: view.frame.width, height: view.frame.height)
                   layout.minimumLineSpacing = 0 // Ensure no spacing between cells
               }
               
               collectionView.isPagingEnabled = true
       }

       override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           return imageNames.count
       }

       override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
           let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! ImageViewCollectionViewCell
           
           cell.imageView.image = UIImage(named: imageNames[indexPath.row])
           return cell
       }

}
