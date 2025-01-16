//
//  HomeViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class HomeViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    
    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Registering Nibs for cells
        let discountsNib = UINib(nibName: "DiscountsCell", bundle: nil)
        let suggestionNib = UINib(nibName: "SuggestionCell", bundle: nil)
        let exploreMoreNib = UINib(nibName: "ExploreMoreCell", bundle: nil)
        
        collectionView.register(discountsNib, forCellWithReuseIdentifier: "DiscountsCell")
        collectionView.register(suggestionNib, forCellWithReuseIdentifier: "SuggestionCell")
        collectionView.register(exploreMoreNib, forCellWithReuseIdentifier: "ExploreMoreCell")
        
        // Registering Header View
        collectionView.register(
            SectionHeaderCollectionReusableView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "SectionHeader"
        )

        // Setting collectionView layout
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)

        // Set data source and delegate
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3 // Discounts, Suggestion, Explore More
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3 // Example: Discounts data count
        case 1:
            return 3 // Example: Suggestion has 3 cards
        case 2:
            return 4// Example: Explore More data count
        default:
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section {
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiscountsCell", for: indexPath) as! DiscountsCollectionViewCell
            cell.layer.cornerRadius = 10
            cell.updateDiscountsData(with: indexPath)
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SuggestionCell", for: indexPath) as! SuggestionCollectionViewCell
            cell.layer.cornerRadius = 13
            cell.updateSuggestionData(with: indexPath)
            return cell
        case 2:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ExploreMoreCell", for: indexPath) as! ExploreMoreCollectionViewCell
            cell.layer.cornerRadius = 13
            cell.updateExploreMoreData(with: indexPath)
            return cell
        default:
            return UICollectionViewCell()
        }
    }

    func generateLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
            let section: NSCollectionLayoutSection
            
            switch sectionIndex {
            case 0:
                section = self.generateDiscountSection()
            case 1:
                section = self.generateSuggestionSection()
            case 2:
                section = self.generateExploreMoreSection()
            default:
                section = self.generateDiscountSection()
            }
            
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]
            return section
        }
        return layout
    }

    func generateDiscountSection() -> NSCollectionLayoutSection {
      // let itemSize = NSCollectionLayoutSize(widthDimension: .absolute(120), heightDimension: .absolute(150))
       
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(130), heightDimension: .absolute(116))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
       // group.interItemSpacing = .fixed(8)
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        return section
    }

    func generateSuggestionSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 0)
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .groupPagingCentered
        return section
    }
    func generateExploreMoreSection() -> NSCollectionLayoutSection {

        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5),
            heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(250)
        )
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.interItemSpacing = .fixed(8)
       
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16 // Spacing between groups
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)

        return section
    }


//    func generateExploreMoreSection() -> NSCollectionLayoutSection {
//     let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .absolute(150))
////       let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
//        let item = NSCollectionLayoutItem(layoutSize: itemSize)
//        //let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(175), heightDimension: .absolute(232))
//        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(232))
//        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
//        group.interItemSpacing = .fixed(8)
//        group.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8)
//        let section = NSCollectionLayoutSection(group: group)
//
//        return section
//    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderCollectionReusableView
            switch indexPath.section {
            case 0:
                header.headerLabel.text = "Discounts"
            case 1:
                header.headerLabel.text = "Suggestion"
            case 2:
                header.headerLabel.text = "Explore More"
            default:
                break
            }
            return header
        }
        return UICollectionReusableView()
    }
}
