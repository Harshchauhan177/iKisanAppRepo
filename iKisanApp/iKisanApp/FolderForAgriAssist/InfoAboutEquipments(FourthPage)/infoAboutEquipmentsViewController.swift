//
//  infoAboutEquipmentsViewController.swift
//  iKisanApp
//
//  Created by Batch - 1 on 20/01/25.
//

import UIKit

class infoAboutEquipmentsViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let firstNib = UINib(nibName: "InfoAboutEquipmentSection1CollectionViewCell", bundle: nil)
        let secondNib = UINib(nibName: "InfoAboutEquipmentSection2CollectionViewCell", bundle: nil)
        collectionView.register(firstNib, forCellWithReuseIdentifier: "First")
        collectionView.register(secondNib, forCellWithReuseIdentifier: "Second")
        
        collectionView.register(SectionHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "SectionHeader")
        
        collectionView.setCollectionViewLayout(generateLayout(), animated: true)
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        ScreenData.sectionHeaderNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            ScreenData.section1Data.count
        case 1:
            ScreenData.section2Data.count
        default:
            0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch indexPath.section{
        case 0:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! InfoAboutEquipmentSection1CollectionViewCell
            cell.updateSection1Data(with: indexPath)
            cell.layer.cornerRadius = 7
            return cell
        case 1:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Second", for: indexPath) as! InfoAboutEquipmentSection2CollectionViewCell
            cell.updateSection2Data(with: indexPath)
            cell.layer.cornerRadius = 7
            return cell
        default:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "First", for: indexPath) as! InfoAboutEquipmentSection1CollectionViewCell
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
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SectionHeader", for: indexPath) as! SectionHeaderCollectionReusableView
            header.headerLabel.text = ScreenData.sectionHeaderNames[indexPath.section]
            header.headerLabel.font = UIFont.systemFont(ofSize: 18,weight: .bold)
            
            header.button.tag = indexPath.section
//            header.button.addTarget(self, action: #selector(SectionButtonTapped(_:)), for: .touchUpInside)
            header.button.setTitle("See All", for: .normal)
            return header
        }
        print("Supplementry item not header")
        return UICollectionReusableView()
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
  
}
