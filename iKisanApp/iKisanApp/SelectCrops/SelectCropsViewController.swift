import UIKit
import Foundation
import Supabase

class SelectCropsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private var dataController = IKisanDataController()
    private var cropList: [AgriCrop] = []
    private var selectedCrops: Set<String> = []
    private var enteredText: [String: String] = [:]
    
    // Flag to indicate if this view controller is being presented from the profile
    var isFromProfile: Bool = false
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = .systemBackground
        return tableView
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You can select crops now or add them later from your profile."
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "No crops available at the moment. You can continue to the app and add crops later."
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isHidden = true
        return label
    }()
    
    private let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Continue to App", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadData()
        
        // Set the title with large appearance
        self.title = "Choose crops you sow (Optional)"
        self.navigationItem.title = "Choose crops you sow (Optional)"
        
        // Configure large title display
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationItem.largeTitleDisplayMode = .always
        
        // Ensure navigation bar is visible
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        tableView.register(UINib(nibName: "OnBoardingTableViewCell", bundle: nil), forCellReuseIdentifier: "OnBoardingTableViewCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        // Register for CropsUpdated notification
        NotificationCenter.default.addObserver(self, selector: #selector(cropsUpdated), name: NSNotification.Name("CropsUpdated"), object: nil)
    }
    
    deinit {
        // Remove notification observer when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(subtitleLabel)
        view.addSubview(tableView)
        view.addSubview(emptyStateLabel)
        view.addSubview(continueButton)
        
        NSLayoutConstraint.activate([
            subtitleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            tableView.topAnchor.constraint(equalTo: subtitleLabel.bottomAnchor, constant: 16),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -20),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            emptyStateLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            continueButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
    }
    
    private func loadData() {
        cropList = dataController.getAllCrops()
        
        // If coming from profile, load the user's previously selected crops
        if isFromProfile {
            selectedCrops = dataController.getSelectedCrops()
            
            // Load saved field areas for the crops
            loadSavedFieldAreas()
            
            // Update the continue button text to reflect we're in profile mode
            continueButton.setTitle("Save Selected Crops", for: .normal)
        }
        
        tableView.reloadData()
        updateContinueButton()
        
        // Show/hide empty state
        emptyStateLabel.isHidden = !cropList.isEmpty
        tableView.isHidden = cropList.isEmpty
    }
    
    @objc private func cropsUpdated() {
        // Called when crops are updated in the data controller
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Get the updated crops list
            self.cropList = self.dataController.getAllCrops()
            
            // Update the UI
            self.tableView.reloadData()
            self.updateContinueButton()
            
            // Show/hide empty state
            self.emptyStateLabel.isHidden = !self.cropList.isEmpty
            self.tableView.isHidden = self.cropList.isEmpty
        }
    }
    
    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = cropList.count
        // Update empty state visibility based on count
        emptyStateLabel.isHidden = count > 0
        tableView.isHidden = count == 0
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "OnBoardingTableViewCell", for: indexPath) as? OnBoardingTableViewCell else {
            return UITableViewCell()
        }
        
        let crop = cropList[indexPath.row]
        let isSelected = selectedCrops.contains(crop.name)
        let text = enteredText[crop.name]
        
        cell.configure(with: crop, isSelected: isSelected, enteredText: text)
        
        // Handle text changes
        cell.onTextChanged = { [weak self] newText in
            if let newText = newText, !newText.isEmpty {
                self?.enteredText[crop.name] = newText
                // Save to DataController immediately so it's available across views
                self?.dataController.saveCropFieldArea(cropName: crop.name, area: newText)
            } else {
                self?.enteredText.removeValue(forKey: crop.name)
                // Remove from DataController if empty
                self?.dataController.saveCropFieldArea(cropName: crop.name, area: "")
            }
            // Reload cell to update height
            tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        return cell
    }
    
    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let crop = cropList[indexPath.row]
        let isSelected = selectedCrops.contains(crop.name)
        let hasText = enteredText[crop.name] != nil && !enteredText[crop.name]!.isEmpty
        
        // Cell should be expanded if:
        // 1. It's currently selected OR
        // 2. It has text entered
        return (isSelected || hasText) ? 95 : 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCrop = cropList[indexPath.row].name
        
        // Toggle selection
        if selectedCrops.contains(selectedCrop) {
            // If deselecting, only remove if no text
            if enteredText[selectedCrop] == nil || enteredText[selectedCrop]!.isEmpty {
                selectedCrops.remove(selectedCrop)
            }
        } else {
            selectedCrops.insert(selectedCrop)  // Allow checkmark even if no text
        }
        
        // Update continue button
        updateContinueButton()
        
        // Animate all changes
        UIView.animate(withDuration: 0.3) {
            tableView.performBatchUpdates({
                tableView.reloadData()
            })
        }
    }
    
    // MARK: - Actions
    @objc private func continueButtonTapped() {
        // Save selected crops (even if empty)
        dataController.setSelectedCrops(selectedCrops)
        
        // Save field areas for all crops that have values entered
        saveFieldAreas()
        
        // Mark crop selection as completed
        UserDefaults.standard.set(true, forKey: "didCompleteCropSelection")
        
        // Reset the new user flag since crop selection is now complete
        UserDefaults.standard.set(false, forKey: "isNewlyRegisteredUser")
        
        // Check if we're coming from profile or onboarding
        if isFromProfile {
            // When coming from profile, just update the data and return to profile
            if let currentUser = AuthManager.shared.currentUser {
                // Get crop IDs for the selected crop names
                let selectedCropIds = cropList
                    .filter { selectedCrops.contains($0.name) }
                    .map { $0.id }
                
                // Show loading indicator
                let loadingAlert = UIAlertController(title: "Updating", message: "Saving your crop selections...", preferredStyle: .alert)
                let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                loadingIndicator.hidesWhenStopped = true
                loadingIndicator.style = .medium
                loadingIndicator.startAnimating()
                loadingAlert.view.addSubview(loadingIndicator)
                present(loadingAlert, animated: true)
                
                Task {
                    do {
                        print("Selected crops updated and saved: \(selectedCrops)")
                        print("Sending \(selectedCropIds.count) crop IDs to Supabase")
                        // Log the IDs we're sending for debugging
                        for (index, id) in selectedCropIds.enumerated() {
                            print("Crop \(index+1): \(id.uuidString)")
                        }
                        
                        // Update crops in Supabase using the new method
                        // Calculate total field area from entered text
                        var totalFieldArea: Double = 0.0
                        
                        for (cropName, areaText) in enteredText {
                            if let area = Double(areaText) {
                                totalFieldArea += area
                                print("Adding \(area) acres for crop: \(cropName)")
                            }
                        }
                        
                        print("Total field area: \(totalFieldArea) acres")
                        
                        do {
                            // Pass both selectedCropIds and totalFieldArea to update method
                            try await AuthManager.shared.updateUserSelectedCrops(
                                selectedCropIds: selectedCropIds,
                                totalFieldArea: totalFieldArea
                            )
                        } catch {
                            // Check if the error is just about the users table
                            let errorDescription = error.localizedDescription
                            if errorDescription.contains("selectedCrops") && errorDescription.contains("users") {
                                print("Ignoring error updating users table as it's not critical: \(error)")
                                // Continue execution as if successful since the userSelectedCrops table was updated
                            } else {
                                // If it's a different error, rethrow it
                                throw error
                            }
                        }
                        
                        // Update successful - dismiss the loading alert and show success
                        await MainActor.run {
                            loadingAlert.dismiss(animated: true) {
                                // Show a brief success message
                                let successAlert = UIAlertController(
                                    title: "Success",
                                    message: "Your crop selections have been updated.",
                                    preferredStyle: .alert
                                )
                                successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                    // Dismiss this view controller to return to profile
                                    // We need to properly navigate back to the profile view
                                    if let presentingVC = self.presentingViewController {
                                        self.dismiss(animated: true)
                                    } else if let navigationController = self.navigationController {
                                        navigationController.popViewController(animated: true)
                                    } else {
                                        // Fallback in case neither works
                                        self.dismiss(animated: true)
                                    }
                                })
                                self.present(successAlert, animated: true)
                            }
                        }
                    } catch {
                        print("Error updating user crops in Supabase: \(error)")
                        // Get more detailed error information
                        // We'll check the error object directly since it will contain the details
                        print("Detailed error information: \(error)")
                        
                        // Show a more informative error message
                        await MainActor.run {
                            loadingAlert.dismiss(animated: true) {
                                // Create a user-friendly error message
                                var errorMessage = "Failed to update crop selections in database."
                                
                                // Extract error details from any error type
                                let errorDetails = "\(error)"
                                errorMessage += " Technical details: \(errorDetails)"
                                
                                self.showAlert(title: "Error", message: errorMessage)
                            }
                        }
                    }
                }
            } else {
                // No user logged in (shouldn't happen from profile, but just in case)
                if let navigationController = self.navigationController {
                    navigationController.popViewController(animated: true)
                } else {
                    dismiss(animated: true)
                }
            }
        } else {
            // Original onboarding flow
            // Update user's selected crops in the database if user is logged in
            if let currentUser = AuthManager.shared.currentUser {
                // Get crop IDs for the selected crop names
                let selectedCropIds = cropList
                    .filter { selectedCrops.contains($0.name) }
                    .map { $0.id }
                
                // Calculate total field area from entered text
                var totalFieldArea: Double = 0.0
                
                for (cropName, areaText) in enteredText {
                    if let area = Double(areaText) {
                        totalFieldArea += area
                        print("Adding \(area) acres for crop: \(cropName)")
                    }
                }
                
                print("Total field area (onboarding): \(totalFieldArea) acres")
                
                // Start an async task to update Supabase
                Task {
                    do {
                        // Update crops and field area in Supabase
                        try await AuthManager.shared.updateUserSelectedCrops(
                            selectedCropIds: selectedCropIds,
                            totalFieldArea: totalFieldArea
                        )
                        // Navigate to main interface
                        await MainActor.run {
                            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                                sceneDelegate.switchToMainInterfaceAfterLogin()
                            }
                        }
                    } catch {
                        print("Error updating user crops and field area: \(error)")
                        // Log the specific error for debugging
                        print("Detailed error information: \(error)")
                        
                        // Still allow proceeding even if there was an error
                        // We'll just use the local update for now
                        await MainActor.run {
                            // Save locally before proceeding
                            var updatedUser = currentUser
                            updatedUser.selectedCrops = selectedCropIds

                            // Save to UserDefaults
                            if let encoded = try? JSONEncoder().encode(updatedUser) {
                                UserDefaults.standard.set(encoded, forKey: "currentUser")
                            }
                            
                            // Continue with main interface
                            if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                                sceneDelegate.switchToMainInterfaceAfterLogin()
                            }
                        }
                    }
                }
            } else {
                // No logged in user, just go to main interface
                if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                    sceneDelegate.switchToMainInterfaceAfterLogin()
                }
            }
        }
        // Method end - the duplicate else clause has been removed
    }
    
    // MARK: - Helper Methods
    private func loadSavedFieldAreas() {
        // Get all saved field areas from DataController
        let savedFieldAreas = dataController.getAllCropFieldAreas()
        
        // Populate the enteredText dictionary with saved values
        for (cropName, fieldArea) in savedFieldAreas {
            enteredText[cropName] = fieldArea
            print("Loaded saved field area for \(cropName): \(fieldArea) acres")
        }
    }
    
    private func saveFieldAreas() {
        // Save all entered field areas to DataController
        dataController.saveCropFieldAreas(areas: enteredText)
    }
    
    private func updateContinueButton() {
        if selectedCrops.isEmpty {
            continueButton.setTitle("Continue to App", for: .normal)
        } else {
            continueButton.setTitle("Continue with Selected Crops", for: .normal)
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
} 