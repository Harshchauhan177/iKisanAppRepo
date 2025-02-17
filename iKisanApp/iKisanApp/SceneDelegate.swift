//
//  SceneDelegate.swift
//  iKisanApp
//
//  Created by Batch - 1 on 15/01/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    var dataController: DataController = IKisanDataController()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        //guard let _ = (scene as? UIWindowScene) else { return }
//        guard let windowScene = (scene as? UIWindowScene) else { return }
//        
//        let window = UIWindow(windowScene: windowScene)
//                
//                // Instantiate your initial ViewController
//         //       let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        //let initialViewController = storyboard.instantiateViewController(identifier: "MainTabBarController") as! MainTabBarController
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let initialViewController = storyboard.instantiateViewController(identifier: "MainTabBarController") as? MainTabBarController{
//        print("Under tab bar controller")
//            let navigationController = UINavigationController(rootViewController: initialViewController)
//            print("Under navigation bar controller")
//            if let homeVC = navigationController.viewControllers[0] as? HomeViewController{
//                print("Under home view controller")
//                homeVC.dataController = dataController
//            }
//        }
//                
//        // Create navigation controller with HomeViewController as root
////        let navigationController = UINavigationController(rootViewController: initialViewController)
////                
////                // Inject the data controller
////                initialViewController.dataController = dataController
//                
//               // window.rootViewController = navigationController
//                self.window = window
//                window.makeKeyAndVisible()
    
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
            let window = UIWindow(windowScene: windowScene)

        //for changing colour of navigation BackButtons
        let appearance = UINavigationBar.appearance()
              appearance.tintColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        
            // Instantiate the storyboard and the MainTabBarController.
            // Make sure the storyboard identifier "MainTabBarController" is set in Interface Builder.
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController,
              let viewControllers = tabBarController.viewControllers else {
            return
        }

        // Initialize dataController
       // let dataController: DataController = IKisanDataController()
        
        // Inject dataController into view controllers
        for viewController in viewControllers {
            if let navController = viewController as? UINavigationController {
                if let homeVC = navController.viewControllers.first as? HomeViewController {
                    homeVC.dataController = dataController
                } else if let agriAssistVC = navController.viewControllers.first as? AgriAssistViewController {
                    agriAssistVC.dataController = dataController
                }
            } else if let homeVC = viewController as? HomeViewController {
                homeVC.dataController = dataController
            } else if let agriAssistVC = viewController as? AgriAssistViewController {
                agriAssistVC.dataController = dataController
            }
        }
//            guard let tabBarController = storyboard.instantiateViewController(withIdentifier: "MainTabBarController") as? UITabBarController else {
//                return
//            }
//
//        // Initialize dataController
////        let dataController: DataController = IKisanDataController()
//        
//            // Iterate through the tab bar controller’s view controllers
//            // to locate the HomeViewController.
//            if let viewControllers = tabBarController.viewControllers {
//                for viewController in viewControllers {
//                    // In many cases, your HomeViewController is embedded in a UINavigationController.
//                    if let navController = viewController as? UINavigationController,
//                       let homeVC = navController.viewControllers.first as? HomeViewController {
//                        // Inject the data controller into HomeViewController.
//                        homeVC.dataController = dataController
//                        break // Stop searching once it's found.
//                    }
//                    // If HomeViewController isn’t embedded, check directly.
//                    else if let homeVC = viewController as? HomeViewController {
//                        homeVC.dataController = dataController
//                        break
//                    }
//                }
//            }

            // Set the tabBarController as the root view controller.
            window.rootViewController = tabBarController
            self.window = window
            window.makeKeyAndVisible()
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

