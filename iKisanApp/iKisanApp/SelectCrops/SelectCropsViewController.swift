import UIKit

class SelectCropsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: - Properties
    private var dataController = IKisanDataController()
    private var cropList: [AgriCrop] = []
    private var selectedCrops: Set<String> = []
    private var enteredText: [String: String] = [:]
    
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
        button.backgroundColor = UIColor(red: 76/255, green: 175/255, blue: 80/255, alpha: 1.0)
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
        tableView.reloadData()
        updateContinueButton()
        
        // Show/hide empty state
        emptyStateLabel.isHidden = !cropList.isEmpty
        tableView.isHidden = cropList.isEmpty
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
            } else {
                self?.enteredText.removeValue(forKey: crop.name)
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
        
        // Mark crop selection as completed
        UserDefaults.standard.set(true, forKey: "didCompleteCropSelection")
        
        // Update user's selected crops in the database if user is logged in
        if let currentUser = AuthManager.shared.currentUser {
            // Get crop IDs for the selected crop names
            let selectedCropIds = cropList
                .filter { selectedCrops.contains($0.name) }
                .map { $0.id }
            
            Task {
                do {
                    // Perform any necessary database updates
                    // For now, we'll just update the local user
                    var updatedUser = currentUser
                    updatedUser.selectedCrops = selectedCropIds
                    
                    // Save to UserDefaults
                    if let encoded = try? JSONEncoder().encode(updatedUser) {
                        UserDefaults.standard.set(encoded, forKey: "currentUser")
                    }
                    
                    // Navigate to main interface
                    await MainActor.run {
                        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
                            sceneDelegate.switchToMainInterfaceAfterLogin()
                        }
                    }
                } catch {
                    print("Error updating user crops: \(error)")
                    // Still allow proceeding even if there was an error
                    await MainActor.run {
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
    
    // MARK: - Helper Methods
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
    
    private func updateContinueButton() {
        if selectedCrops.isEmpty {
            continueButton.setTitle("Continue to App", for: .normal)
        } else {
            continueButton.setTitle("Continue with Selected Crops", for: .normal)
        }
    }
} 