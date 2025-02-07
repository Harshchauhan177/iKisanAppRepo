//
//  UpcomingBookingsListViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 22/01/25.
//

import UIKit

class UpcomingBookingsListViewController: UIViewController, UICollectionViewDataSource,UpcomingBookingsListCellDelegate {

    private let reuseIdentifier = "BookListCell"
    private var upcomingBookings: [Booking] = []
    private var dataController: DataController?
    private var allEquipment: [Equipment] = []
    
    @IBOutlet var collectionView: UICollectionView!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()


        if let windowScene = view.window?.windowScene,
           let sceneDelegate = windowScene.delegate as? SceneDelegate {
            self.dataController = sceneDelegate.dataController
            // Load equipment data
            allEquipment = dataController?.getAllEquipment() ?? []
            // TODO: Load upcoming bookings when implemented in DataController
        }
        collectionView.setCollectionViewLayout(genrateLayout(), animated: true)
        collectionView.dataSource = self
        // Do any additional setup after loading the view.
    }
    
    
    
    private func genrateLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(115))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        group.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
        let section = NSCollectionLayoutSection(group: group)
        //section.orthogonalScrollingBehavior = .groupPagingCentered
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        upcomingBookings.count //return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! UpcomingBookingsListCollectionViewCell
        
        //let country = countries[indexPath.item]
        let booking = upcomingBookings[indexPath.row]
        if let equipment = allEquipment.first(where: { $0.equipmentID == booking.equipmentID }) {
            cell.updateCellData(with: booking, equipment: equipment)
        }
//        cell.equipmentNameLabel.text = "Equipment Name"
//        cell.updateCellData(with: indexPath)
        cell.delegate = self
        return cell
    }
    
    func didTapViewButton(on cell: UpcomingBookingsListCollectionViewCell) {
        
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let booking = upcomingBookings[indexPath.row]
        guard let equipment = allEquipment.first(where: { $0.equipmentID == booking.equipmentID }) else { return }
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "BookingDetailsViewController") as? BookingDetailsViewController {
            viewController.modalPresentationStyle = .fullScreen
            viewController.equipment = equipment
            viewController.booking = booking
            navigationController?.pushViewController(viewController, animated: true)
        }
        
//        // Get the indexPath of the cell
//        if let indexPath = collectionView.indexPath(for: cell) {
//            print("View button tapped on cell at index: \(indexPath.row)")
//        }
//        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
//        if let viewController = storyboard.instantiateViewController(withIdentifier: "BookingDetailsViewController") as? BookingDetailsViewController {
//            //viewController.modalTransitionStyle = .crossDissolve
//            viewController.modalPresentationStyle = .fullScreen // Optional: Set presentation style
//            //present(viewController, animated: true, completion: nil)
//            navigationController?.pushViewController(viewController, animated: true)
//        }
//        
   }
    
}
