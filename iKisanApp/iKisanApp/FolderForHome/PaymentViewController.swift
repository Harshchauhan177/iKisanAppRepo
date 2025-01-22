//
//  PaymentViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 21/01/25.
//

import UIKit

class PaymentViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func walletButtonTapped(_ sender: UIButton) {
      
        let alertController = UIAlertController(
                title: "Payment Successful",
                message: "Your payment is done, and the booking has been added to upcoming bookings.",
                preferredStyle: .alert
            )
            
            let okAction = UIAlertAction(title: "Done", style: .default) { [weak self] _ in
                self?.navigateToHomeScreen()
            }
            alertController.addAction(okAction)
            
            present(alertController, animated: true, completion: nil)
        }

    private func navigateToHomeScreen() {
        // Dismiss PaymentViewController if it was presented modally
        dismiss(animated: true) {
        //     Replace the navigation stack with HomeViewController
            let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
            if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                homeViewController.modalPresentationStyle = .fullScreen
               homeViewController.hasUpcomingBookings = true
                UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: homeViewController)
            }

            
        }
    }
    
}
