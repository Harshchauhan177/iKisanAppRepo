import UIKit

// Coordinator pattern to handle navigation to UserListView
class UserListCoordinator {
    weak var navigationController: UINavigationController?
    var dataController: DataController
    
    init(navigationController: UINavigationController, dataController: DataController) {
        self.navigationController = navigationController
        self.dataController = dataController
    }
    
    func start() {
        let userListVC = UserListViewController()
        userListVC.dataController = dataController
        userListVC.title = "All Users"
        
        navigationController?.pushViewController(userListVC, animated: true)
    }
    
    func startAsModal(from presentingVC: UIViewController, completion: (() -> Void)? = nil) {
        let userListVC = UserListViewController()
        userListVC.dataController = dataController
        userListVC.title = "All Users"
        
        let navController = UINavigationController(rootViewController: userListVC)
        
        // Add a done button to dismiss the modal
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: nil)
        doneButton.action = #selector(userListVC.dismissModal)
        userListVC.navigationItem.rightBarButtonItem = doneButton
        
        presentingVC.present(navController, animated: true, completion: completion)
    }
}

// Extension to add the dismiss method to UIViewController
extension UIViewController {
    @objc func dismissModal() {
        dismiss(animated: true, completion: nil)
    }
} 