import UIKit

class ProfileViewController: UIViewController {
    // MARK: - UI Components
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let avatarImageView = UIImageView()
    private let nameLabel = UILabel()
    private let emailLabel = UILabel()
    private let phoneLabel = UILabel()
    private let cropsTitleLabel = UILabel()
    private let cropsStackView = UIStackView()
    private let editButton = UIButton(type: .system)
    private let logoutButton = UIButton(type: .system)
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadUserData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Profile"
        navigationItem.largeTitleDisplayMode = .always
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        // Avatar
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.image = UIImage(systemName: "person.crop.circle.fill")
        avatarImageView.tintColor = .systemGreen
        avatarImageView.contentMode = .scaleAspectFill
        avatarImageView.layer.cornerRadius = 50
        avatarImageView.clipsToBounds = true
        contentView.addSubview(avatarImageView)
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 32),
            avatarImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            avatarImageView.widthAnchor.constraint(equalToConstant: 100),
            avatarImageView.heightAnchor.constraint(equalToConstant: 100)
        ])
        
        // Name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        nameLabel.textAlignment = .center
        contentView.addSubview(nameLabel)
        NSLayoutConstraint.activate([
            nameLabel.topAnchor.constraint(equalTo: avatarImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        // Email
        emailLabel.translatesAutoresizingMaskIntoConstraints = false
        emailLabel.font = UIFont.systemFont(ofSize: 16)
        emailLabel.textColor = .secondaryLabel
        emailLabel.textAlignment = .center
        contentView.addSubview(emailLabel)
        NSLayoutConstraint.activate([
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            emailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        // Phone
        phoneLabel.translatesAutoresizingMaskIntoConstraints = false
        phoneLabel.font = UIFont.systemFont(ofSize: 16)
        phoneLabel.textColor = .secondaryLabel
        phoneLabel.textAlignment = .center
        contentView.addSubview(phoneLabel)
        NSLayoutConstraint.activate([
            phoneLabel.topAnchor.constraint(equalTo: emailLabel.bottomAnchor, constant: 4),
            phoneLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            phoneLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        // Edit button
        editButton.translatesAutoresizingMaskIntoConstraints = false
        editButton.setTitle("Edit Profile", for: .normal)
        editButton.setTitleColor(.systemBlue, for: .normal)
        editButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        contentView.addSubview(editButton)
        NSLayoutConstraint.activate([
            editButton.topAnchor.constraint(equalTo: phoneLabel.bottomAnchor, constant: 12),
            editButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor)
        ])
        
        // Crops title
        cropsTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        cropsTitleLabel.text = "Selected Crops"
        cropsTitleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        cropsTitleLabel.textColor = .label
        contentView.addSubview(cropsTitleLabel)
        NSLayoutConstraint.activate([
            cropsTitleLabel.topAnchor.constraint(equalTo: editButton.bottomAnchor, constant: 32),
            cropsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cropsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        // Crops stack view
        cropsStackView.translatesAutoresizingMaskIntoConstraints = false
        cropsStackView.axis = .vertical
        cropsStackView.spacing = 8
        contentView.addSubview(cropsStackView)
        NSLayoutConstraint.activate([
            cropsStackView.topAnchor.constraint(equalTo: cropsTitleLabel.bottomAnchor, constant: 8),
            cropsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            cropsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24)
        ])
        
        // Logout button
        logoutButton.translatesAutoresizingMaskIntoConstraints = false
        logoutButton.setTitle("Logout", for: .normal)
        logoutButton.setTitleColor(.systemRed, for: .normal)
        logoutButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        logoutButton.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        contentView.addSubview(logoutButton)
        NSLayoutConstraint.activate([
            logoutButton.topAnchor.constraint(equalTo: cropsStackView.bottomAnchor, constant: 40),
            logoutButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            logoutButton.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -32)
        ])
    }
    
    private func loadUserData() {
        guard let user = AuthManager.shared.currentUser else { return }
        nameLabel.text = user.name
        emailLabel.text = user.email
        phoneLabel.text = user.phone
        
        // Crops
        cropsStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        if let crops = user.selectedCrops, !crops.isEmpty {
            for cropId in crops {
                let label = UILabel()
                label.font = UIFont.systemFont(ofSize: 16)
                label.textColor = .label
                label.text = "Crop ID: \(cropId.uuidString)" // You can fetch crop names if you have a mapping
                cropsStackView.addArrangedSubview(label)
            }
        } else {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = .secondaryLabel
            label.text = "No crops selected."
            cropsStackView.addArrangedSubview(label)
        }
    }
    
    @objc private func editButtonTapped() {
        let alert = UIAlertController(title: "Edit Profile", message: nil, preferredStyle: .alert)
        alert.addTextField { $0.text = self.nameLabel.text; $0.placeholder = "Name" }
        alert.addTextField { $0.text = self.phoneLabel.text; $0.placeholder = "Phone"; $0.keyboardType = .phonePad }
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            guard let self = self else { return }
            let newName = alert.textFields?[0].text ?? ""
            let newPhone = alert.textFields?[1].text ?? ""
            Task {
                do {
                    try await AuthManager.shared.updateUserProfile(name: newName, phone: newPhone)
                    await MainActor.run { self.loadUserData() }
                } catch {
                    await MainActor.run {
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to update profile.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive) { [weak self] _ in
            Task {
                do {
                    try await AuthManager.shared.logout()
                    await MainActor.run {
                        if let sceneDelegate = self?.view.window?.windowScene?.delegate as? SceneDelegate {
                            sceneDelegate.switchToLogin()
                        }
                    }
                } catch {
                    await MainActor.run {
                        let errorAlert = UIAlertController(title: "Error", message: "Failed to logout.", preferredStyle: .alert)
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self?.present(errorAlert, animated: true)
                    }
                }
            }
        })
        present(alert, animated: true)
    }
} 