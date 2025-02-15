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
      
        guard let booking = self.booking else {
            return
        }
        
        guard let dataController = self.dataController else {
            return
        }
        
        // Add the confirmed booking
        var confirmedBooking = booking
        confirmedBooking.status = .confirmed
        dataController.addBooking(confirmedBooking)
        
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
              let sceneDelegate = windowScene.delegate as? SceneDelegate else {
            return
        }
        guard let tabBarController = windowScene.windows.first?.rootViewController as? UITabBarController else {
            return
        }
        tabBarController.selectedIndex = 0
        guard let navController = tabBarController.selectedViewController as? UINavigationController else {
            return
        }
        
        navController.popToRootViewController(animated: false)
        
        if let homeVC = navController.viewControllers.first as? HomeViewController {
            // Update HomeViewController
            let upcomingBookings = sceneDelegate.dataController.getUpcomingBookings()
            homeVC.upcomingBookings = upcomingBookings
            homeVC.hasUpcomingBookings = !upcomingBookings.isEmpty
            homeVC.collectionView.reloadData()
            
            // Dismiss all modally presented views
            self.dismiss(animated: true)
        }
    }

}
