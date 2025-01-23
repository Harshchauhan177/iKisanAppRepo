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
            
            if let tabBarController = UIApplication.shared.windows.first?.rootViewController as? UITabBarController {
                // Ensure we're in the correct tab (e.g., index 0 for "Home")
                tabBarController.selectedIndex = 0
                
                // Access the NavigationController within the TabBarController
                if let navigationController = tabBarController.viewControllers?.first as? UINavigationController {
                    let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
                    if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                        homeViewController.hasUpcomingBookings = true
                        
                        // Replace or push to the HomeViewController
                        navigationController.setViewControllers([homeViewController], animated: true)
                    }
                }
                
                //            let storyboard = UIStoryboard(name: "Tab1Home", bundle: nil)
                //            if let homeViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                //                homeViewController.modalPresentationStyle = .fullScreen
                //               homeViewController.hasUpcomingBookings = true
                //               UIApplication.shared.windows.first?.rootViewController = UINavigationController(rootViewController: homeViewController)
                //            }
            }
            
        }
    }
    
}
