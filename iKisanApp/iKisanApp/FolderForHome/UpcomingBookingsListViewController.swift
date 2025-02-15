//
//  UpcomingBookingsListViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 22/01/25.
//

import UIKit

class UpcomingBookingsListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UpcomingBookingsListCellDelegate {

    private let reuseIdentifier = "BookListCell"
    
    var dataController: DataController?
    var upcomingBookings: [Booking] = []
    var allEquipment: [Equipment] = []
    
    @IBOutlet var collectionView: UICollectionView!
    
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // Only fetch from dataController if data wasn't passed
        if upcomingBookings.isEmpty || allEquipment.isEmpty {
            if let dataController = dataController {
                allEquipment = dataController.getAllEquipment()
                upcomingBookings = dataController.getUpcomingBookings()
            } else {
                print("UpcomingBookingsListViewController - Warning: No dataController available")
            }
        }
        
        setupUI()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh data when view appears
        if let dataController = dataController {
            upcomingBookings = dataController.getUpcomingBookings()
            collectionView.reloadData()
        }
    }
    
    private func setupUI() {
        title = "Upcoming Bookings"
        navigationItem.largeTitleDisplayMode = .never
        
        // Add a message for no bookings
        if upcomingBookings.isEmpty {
            let messageLabel = UILabel()
            messageLabel.text = "No upcoming bookings"
            messageLabel.textAlignment = .center
            messageLabel.textColor = .gray
            messageLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 40)
            messageLabel.center = view.center
            view.addSubview(messageLabel)
        }
    }
    
    private func setupCollectionView() {
       
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 8
            layout.minimumInteritemSpacing = 8
            
            // Calculate cell size
            let width = collectionView.bounds.width - 16
            layout.itemSize = CGSize(width: width, height: 180)
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingBookings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                    for: indexPath) as! UpcomingBookingsListCollectionViewCell
        
        let booking = upcomingBookings[indexPath.row]
        
        if let equipment = allEquipment.first(where: { $0.equipmentID == booking.equipmentID }) {
            cell.delegate = self
            cell.updateCellData(with: booking, equipment: equipment)
           
        }
        
        return cell
    }
    
    // MARK: - UpcomingBookingsListCellDelegate
    
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
    }
}
