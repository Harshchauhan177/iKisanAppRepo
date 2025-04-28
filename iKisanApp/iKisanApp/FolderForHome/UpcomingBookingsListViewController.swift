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
        
        // Debug information
        print("UpcomingBookingsListViewController - viewDidLoad called")
        
        // First check if the collectionView outlet is connected
        guard collectionView != nil else {
            print("ERROR: collectionView outlet is nil in UpcomingBookingsListViewController")
            return
        }
        
        // Check if dataController exists
        guard dataController != nil else {
            print("ERROR: dataController is nil in UpcomingBookingsListViewController")
            return
        }
        
        // Setup UI first
        setupUI()
        setupCollectionView()
        
        // Then fetch data immediately
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("UpcomingBookingsListViewController - viewWillAppear called")
        
        // Always reload data when view appears
        loadData()
    }
    
    private func setupUI() {
        title = "Upcoming Bookings"
        navigationItem.largeTitleDisplayMode = .never
        
        // Handle no bookings message
        updateNoBookingsMessage()
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
    
    private func updateNoBookingsMessage() {
        // Remove any existing message labels
        for subview in view.subviews {
            if let label = subview as? UILabel, label.tag == 100 {
                label.removeFromSuperview()
            }
        }
        
        // Add a message if there are no bookings
        if upcomingBookings.isEmpty {
            let messageLabel = UILabel()
            messageLabel.tag = 100 // Tag for easy identification
            messageLabel.text = "No upcoming bookings"
            messageLabel.textAlignment = .center
            messageLabel.textColor = .gray
            messageLabel.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 40)
            messageLabel.center = view.center
            view.addSubview(messageLabel)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingBookings.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier,
                                                    for: indexPath) as! UpcomingBookingsListCollectionViewCell
        
        let booking = upcomingBookings[indexPath.row]
        
        // First try exact ID match
        if let equipment = allEquipment.first(where: { equip in 
            equip.equipmentID.uuidString.lowercased() == booking.equipmentID.uuidString.lowercased() 
        }) {
            print("Found matching equipment: \(equipment.name)")
            cell.delegate = self
            cell.updateCellData(with: booking, equipment: equipment)
        } 
        // If exact match fails, try to get equipment by ID from dataController
        else if let dataController = dataController, 
                let matchingEquipment = dataController.getEquipment(byId: booking.equipmentID) {
            print("Found equipment using dataController: \(matchingEquipment.name)")
            cell.delegate = self
            cell.updateCellData(with: booking, equipment: matchingEquipment)
        }
        // Last resort, use first equipment as fallback - ensures something displays
        else if !allEquipment.isEmpty {
            let fallbackEquipment = allEquipment[0]
            print("WARNING: Using fallback equipment: \(fallbackEquipment.name)")
            cell.delegate = self
            cell.updateCellData(with: booking, equipment: fallbackEquipment)
        }
        else {
            print("ERROR: Cannot find any equipment for booking: \(booking.bookingID)")
        }
        
        return cell
    }
    
    // MARK: - UpcomingBookingsListCellDelegate
    
    func didTapViewButton(on cell: UpcomingBookingsListCollectionViewCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let booking = upcomingBookings[indexPath.row]
        
        // Find the equipment using the same robust approach as in cellForItemAt
        var equipmentToUse: Equipment?
        
        // First try exact ID match
        if let equipment = allEquipment.first(where: { equip in 
            equip.equipmentID.uuidString.lowercased() == booking.equipmentID.uuidString.lowercased() 
        }) {
            equipmentToUse = equipment
        } 
        // If exact match fails, try to get equipment by ID from dataController
        else if let dataController = dataController, 
                let matchingEquipment = dataController.getEquipment(byId: booking.equipmentID) {
            equipmentToUse = matchingEquipment
        }
        // Last resort, use first equipment as fallback if needed
        else if !allEquipment.isEmpty {
            equipmentToUse = allEquipment[0]
            print("WARNING: Using fallback equipment in didTapViewButton")
        }
        
        guard let equipment = equipmentToUse else {
            print("ERROR: Cannot find any equipment for booking: \(booking.bookingID)")
            return
        }
        
        let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "BookingDetailsViewController") as? BookingDetailsViewController {
            viewController.modalPresentationStyle = .fullScreen
            viewController.equipment = equipment
            viewController.booking = booking
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    // Add a dedicated method for loading data
    private func loadData() {
        print("UpcomingBookingsListViewController - loadData() called")
        
        Task {
            // First try direct fetch from RequestManager
            let fetchedBookings = await RequestManager.shared.fetchBookings()
            let fetchedEquipment = await RequestManager.shared.fetchEquipments()
            
            await MainActor.run {
                self.upcomingBookings = fetchedBookings
                self.allEquipment = fetchedEquipment
                
                print("UpcomingBookingsListViewController - Direct fetch loaded \(self.upcomingBookings.count) bookings and \(self.allEquipment.count) equipment items")
                
                // If we have no bookings or equipment but we have a dataController, try that as fallback
                if (self.upcomingBookings.isEmpty || self.allEquipment.isEmpty) && self.dataController != nil {
                    self.allEquipment = self.dataController!.getAllEquipment()
                    self.upcomingBookings = self.dataController!.getUpcomingBookings()
                    print("UpcomingBookingsListViewController - Fallback to dataController loaded \(self.upcomingBookings.count) bookings")
                }
                
                // Reload collection view and update message
                self.collectionView.reloadData()
                self.updateNoBookingsMessage()
            }
        }
    }
}
