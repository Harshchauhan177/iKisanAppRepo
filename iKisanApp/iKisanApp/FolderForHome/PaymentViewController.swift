//
//  PaymentViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit

class PaymentViewController: UIViewController {
    
    
    
    var booking: Booking?
    private var dataController: DataController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get DataController from SceneDelegate
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        
        self.dataController = sceneDelegate.dataController
        
        // For Verify booking was passed correctly
        if let booking = self.booking {
            // Set navigation title
            title = "Payment"
        } else {
            print("PaymentViewController - No booking received!")
            // Show error and pop back
            DispatchQueue.main.async {
                let alert = UIAlertController(
                    title: "Error",
                    message: "No booking information found",
                    preferredStyle: .alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
                    self?.navigationController?.popViewController(animated: true)
                })
                self.present(alert, animated: true)
            }
        }
    }
    
    deinit {
        print("PaymentViewController - deinit called")
    }
    
    
    @IBAction func walletButtonTapped(_ sender: UIButton) {
        
        guard let booking = self.booking,
              let dataController = self.dataController else { return }
        
        // Add the confirmed booking
        var confirmedBooking = booking
        confirmedBooking.status = .confirmed
        dataController.addBooking(confirmedBooking)
        
        // Post notification for prebooking
        if booking.bookingType == .prebooking {
            NotificationCenter.default.post(
                name: .preBookingAdded,
                object: nil,
                userInfo: ["booking": confirmedBooking]
            )
        }
        
        let alertController = UIAlertController(
            title: "Payment Successful",
            message: "Your booking has been confirmed",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
            self?.navigateToHome()
        }
        okAction.setValue(UIColor.init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    private func navigateToHome() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController else {
            return
        }
        
        // Check if the booking is from prebooking
        if let booking = booking, booking.source == .prebooking {
            // Navigate to Prebooking tab
            tabBarController.selectedIndex = 1 // Index 1 is the Prebooking tab
            
            if let navController = tabBarController.selectedViewController as? UINavigationController,
               let prebookingVC = navController.viewControllers.first as? PrebookingViewController {
                // Pop to root of prebooking tab
                navController.popToRootViewController(animated: false)
                
                // Update prebooking view controller and trigger a reload
                DispatchQueue.main.async {
                    // Get fresh data
                    let preBookings = sceneDelegate.dataController.getPreBookings()
                    let preBookingEquipments = preBookings.compactMap { booking in
                        sceneDelegate.dataController.getEquipment(byId: booking.equipmentID)
                    }
                    
                    // Update the view controller
                    prebookingVC.preBookings = preBookings
                    prebookingVC.preBookingEquipments = preBookingEquipments
                    
                    // Reload collection view
                    prebookingVC.collectionView.reloadData()
                    
                    // Scroll to prebookings section after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        prebookingVC.scrollToSectionHeader(section: PrebookingViewController.Section.prebookings.rawValue)
                    }
                }
            }
        } else {
            // Original home tab navigation for non-prebooking bookings
            tabBarController.selectedIndex = 0
            if let navController = tabBarController.selectedViewController as? UINavigationController,
               let homeVC = navController.viewControllers.first as? HomeViewController {
                navController.popToRootViewController(animated: false)
                
                // Update HomeViewController
                let upcomingBookings = sceneDelegate.dataController.getUpcomingBookings()
                homeVC.upcomingBookings = upcomingBookings
                homeVC.hasUpcomingBookings = !upcomingBookings.isEmpty
                homeVC.collectionView.reloadData()
            }
        }
        
        // Dismiss payment view controller
        self.dismiss(animated: true)
    }
    @IBAction func confirmPaymentTapped(_ sender: Any) {
        guard let booking = booking else { return }
        
        // Add the booking to the data controller
        if let dataController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.dataController {
            dataController.addBooking(booking)
            
            // Post notification for prebooking if applicable
            if booking.bookingType == .prebooking {
                NotificationCenter.default.post(
                    name: .preBookingAdded,
                    object: nil,
                    userInfo: ["booking": booking]
                )
            }
        }
        
        // ... rest of the payment confirmation code ...
    }

}
