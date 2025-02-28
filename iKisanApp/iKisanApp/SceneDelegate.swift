//
//  SceneDelegate.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    // Your shared DataController instance.
    var dataController: DataController = IKisanDataController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        UINavigationBar.appearance().tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if !hasCompletedOnboarding {
            // Load onboarding if not complete
            guard let onboardingVC = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController else { return }
            window.rootViewController = onboardingVC
        } else {
            // Load the main interface with DataController injection
            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController,
                  let viewControllers = tabBarController.viewControllers else { return }
            
            // Initialize HomeViewController with saved crop selections
            for viewController in viewControllers {
                if let navController = viewController as? UINavigationController {
                    if let homeVC = navController.viewControllers.first as? HomeViewController {
                        homeVC.dataController = dataController
                        // Refresh suggestions immediately based on saved crops
                        homeVC.loadViewIfNeeded()
                    } else if let agriAssistVC = navController.viewControllers.first as? AgriAssistViewController {
                        agriAssistVC.dataController = dataController
                    } else if let coequipVC = navController.viewControllers.first as? CoequipViewController {
                        coequipVC.dataController = dataController
                    }
                } else if let homeVC = viewController as? HomeViewController {
                    homeVC.dataController = dataController
                    // Refresh suggestions immediately based on saved crops
                    homeVC.loadViewIfNeeded()
                } else if let agriAssistVC = viewController as? AgriAssistViewController {
                    agriAssistVC.dataController = dataController
                } else if let coequipVC = viewController as? CoequipViewController {
                    coequipVC.dataController = dataController
                }
            }
            window.rootViewController = tabBarController
        }
        
        self.window = window
        window.makeKeyAndVisible()
    }
    
    // Helper method to transition to the main interface after onboarding.
    func switchToMainInterface() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Check if we're coming from onboarding and haven't shown crop selection
        if !UserDefaults.standard.bool(forKey: "hasCompletedOnboarding") {
            if let selectCropsVC = storyboard.instantiateViewController(withIdentifier: "selectSessionCropsViewController") as? selectSessionCropsViewController {
                selectCropsVC.datacontroller = self.dataController as! IKisanDataController
                
                // Wrap in navigation controller
                let navigationController = UINavigationController(rootViewController: selectCropsVC)
                
                guard let window = self.window else { return }
                window.rootViewController = navigationController
                return
            }
        }
        
        // Otherwise proceed to main interface
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController,
              let viewControllers = tabBarController.viewControllers else { return }
        
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController {
                if let homeVC = navController.viewControllers.first as? HomeViewController {
                    homeVC.dataController = dataController
                } else if let agriAssistVC = navController.viewControllers.first as? AgriAssistViewController {
                    agriAssistVC.dataController = dataController
                } else if let coequipVC = navController.viewControllers.first as? CoequipViewController {
                    coequipVC.dataController = dataController
                }
            } else if let homeVC = viewController as? HomeViewController {
                homeVC.dataController = dataController
            } else if let agriAssistVC = viewController as? AgriAssistViewController {
                agriAssistVC.dataController = dataController
            } else if let coequipVC = viewController as? CoequipViewController {
                coequipVC.dataController = dataController
            }
        }
        
        guard let window = self.window else { return }
        window.rootViewController = tabBarController
        
        // Optional animated transition.
       // UIView.transition(with: window, duration: 0.5, options: [.transitionFlipFromRight], animations: nil)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

