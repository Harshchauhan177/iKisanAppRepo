//
//  BookingDetailsViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 23/01/25.
//

import UIKit

class BookingDetailsViewController: UIViewController {
    
    // MARK: - Properties
    var equipment: Equipment?
    var booking: Booking?
    private let requestManager = RequestManager.shared
    private var usingProgrammaticUI = true

    // MARK: - Outlets from Storyboard
    // Keep these to prevent crashes from storyboard connections
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var imageView: UIImageView?
    @IBOutlet var priceLabel: UILabel?
    @IBOutlet var equipmentNameLabel: UILabel?
    @IBOutlet var hostedByLabel: UILabel?
    @IBOutlet var providerNameLabel: UILabel?
    @IBOutlet var mobileNoLabel: UILabel?
    @IBOutlet var ratingLabel: UILabel?
    @IBOutlet var backgroundCollectionView: UIView?
    
    // Add these outlets back to prevent crash - they're connected in storyboard
    @IBOutlet weak var fieldAreaLabel: UILabel?
    @IBOutlet weak var statusLabel: UILabel?
    @IBOutlet weak var locationLabel: UILabel?
    @IBOutlet weak var timeSlotLabel: UILabel?
    
    // Additional UI elements created programmatically
    private var scrollView: UIScrollView!
    private var contentView: UIView!
    
    private var dateHeaderLabel: UILabel!
    private var equipmentCardView: UIView!
    private var importantDetailsHeaderLabel: UILabel!
    private var ownerDetailsHeaderLabel: UILabel!
    
    private var fieldAreaTitleLabel: UILabel!
    private var fieldAreaValueLabel: UILabel!
    private var statusTitleLabel: UILabel!
    private var statusValueLabel: UILabel!
    private var locationTitleLabel: UILabel!
    private var locationValueLabel: UILabel!
    private var timeSlotTitleLabel: UILabel!
    private var timeSlotValueLabel: UILabel!
    
    private var nameTitleLabel: UILabel!
    private var nameValueLabel: UILabel!
    private var mobileTitleLabel: UILabel!
    private var mobileValueLabel: UILabel!
    private var ratingTitleLabel: UILabel!
    private var ratingValueView: UIView!
    private var ratingValueLabel: UILabel!
    
    private var cancelButton: UIButton!
    
    // Spacing constants
    private let horizontalPadding: CGFloat = 24
    private let verticalPadding: CGFloat = 16
    private let sectionSpacing: CGFloat = 30
    private let rowSpacing: CGFloat = 16
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Print debug information
        print("BookingDetailsViewController - viewDidLoad called")
        if let equipment = equipment, let booking = booking {
            print("BookingDetailsViewController - Equipment: \(equipment.name), Booking ID: \(booking.bookingID)")
        } else {
            print("ERROR: Missing equipment or booking data")
        }
        
        // Check if we should use the programmatic UI
        checkStoryboardUI()
        
        // If using programmatic UI, set it up
        if usingProgrammaticUI {
            setupNavigationBar()
            setupScrollView()
            buildUI()
            populateData()
        } else {
            populateStoryboardUI()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if usingProgrammaticUI {
            // Refresh UI once the view has appeared to fix any layout issues
            contentView.layoutIfNeeded()
        }
    }
    
    // MARK: - UI Setup
    
    private func checkStoryboardUI() {
        // If critical UI elements are connected in storyboard, use those instead
        if fieldAreaLabel != nil && statusLabel != nil && locationLabel != nil && timeSlotLabel != nil {
            print("Using storyboard UI elements")
            usingProgrammaticUI = false
        } else {
            print("Using programmatic UI elements")
            usingProgrammaticUI = true
        }
    }
    
    private func populateStoryboardUI() {
        // Fallback to using the storyboard UI elements
        guard let booking = booking, let equipment = equipment else {
            print("Missing booking or equipment data")
            return
        }
        
        // Set equipment image
        if let image = UIImage(named: equipment.equipmentImage) {
            imageView?.image = image
        } else {
            imageView?.image = UIImage(named: "placeholder_equipment")
            print("Warning: Equipment image \(equipment.equipmentImage) not found")
        }
        
        // Set equipment details
        equipmentNameLabel?.text = equipment.name
        priceLabel?.text = "₹ \(Int(equipment.pricePerHour))/hr"
        
        // Format and set booking date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM"
        dateLabel?.text = dateFormatter.string(from: booking.bookingDate)
        
        // Set booking details
        fieldAreaLabel?.text = String(format: "%.1f", booking.fieldArea)
        
        // Set status with appropriate color
        let statusText = booking.status.rawValue.prefix(1).uppercased() + booking.status.rawValue.dropFirst()
        statusLabel?.text = statusText
        if booking.status == .confirmed {
            statusLabel?.textColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        } else if booking.status == .pending {
            statusLabel?.textColor = .systemOrange
        }
        
        // Set location and time slot
        locationLabel?.text = equipment.location.isEmpty ? "LocationLbl" : equipment.location
        timeSlotLabel?.text = booking.timeSlot.rawValue
        
        // Set provider info with default values
        providerNameLabel?.text = "harsh7617..."
        mobileNoLabel?.text = "8865830412"
        ratingLabel?.text = "4.5"
        
        // Fetch provider info from backend
        fetchProviderInfoForStoryboard()
    }
    
    private func fetchProviderInfoForStoryboard() {
        Task {
            guard let userId = booking?.userID else {
                print("Error: No user ID available in booking")
                return
            }
            
            do {
                let result = try await SupabaseManager.shared.client
                    .from("users")
                    .select("*")
                    .eq("userID", value: userId.uuidString)
                    .execute()
                
                do {
                    let json = try JSONSerialization.jsonObject(with: result.data)
                    print("User fetch returned: \(json)")
                    
                    if let users = json as? [[String: Any]], let user = users.first {
                        // Extract user data
                        let name = user["name"] as? String ?? "harsh7617..."
                        let phone = user["phone"] as? String ?? "8865830412"
                        
                        // Update UI on main thread
                        await MainActor.run { [weak self] in
                            guard let self = self else { return }
                            self.providerNameLabel?.text = name
                            self.mobileNoLabel?.text = phone
                            print("✅ Updated provider info: name=\(name), phone=\(phone)")
                        }
                    }
                } catch {
                    print("❌ Error parsing user data: \(error)")
                }
            } catch {
                print("❌ Error fetching provider info: \(error)")
            }
        }
    }
    
    private func setupNavigationBar() {
        // Set title and back button
        navigationItem.title = "Booking Details"
        navigationController?.navigationBar.tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        navigationController?.navigationBar.topItem?.backButtonTitle = "Back"
    }
    
    private func setupScrollView() {
        // Add scroll view to contain all content
        scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Add content view inside scroll view
        contentView = UIView()
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Set up constraints
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
    }
    
    private func buildUI() {
        // Set background color
        view.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)
        
        // Create date header
        createDateHeader()
        
        // Create equipment card
        createEquipmentCard()
        
        // Create Important Details section
        createImportantDetailsSection()
        
        // Create Owner Details section
        createOwnerDetailsSection()
        
        // Create Cancel button
        createCancelButton()
        
        // Set content view height to accommodate all content
        let bottomConstraint = cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -verticalPadding)
        bottomConstraint.priority = .defaultHigh
        bottomConstraint.isActive = true
    }
    
    private func createDateHeader() {
        dateHeaderLabel = UILabel()
        dateHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        dateHeaderLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        dateHeaderLabel.textColor = .black
        contentView.addSubview(dateHeaderLabel)
        
        NSLayoutConstraint.activate([
            dateHeaderLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: verticalPadding),
            dateHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            dateHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
    }
    
    private func createEquipmentCard() {
        equipmentCardView = UIView()
        equipmentCardView.translatesAutoresizingMaskIntoConstraints = false
        equipmentCardView.backgroundColor = .white
        equipmentCardView.layer.cornerRadius = 16
        equipmentCardView.layer.shadowColor = UIColor.black.cgColor
        equipmentCardView.layer.shadowOpacity = 0.1
        equipmentCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        equipmentCardView.layer.shadowRadius = 4
        contentView.addSubview(equipmentCardView)
        
        NSLayoutConstraint.activate([
            equipmentCardView.topAnchor.constraint(equalTo: dateHeaderLabel.bottomAnchor, constant: verticalPadding),
            equipmentCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            equipmentCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        // Add equipment image
        let equipmentImage = UIImageView()
        equipmentImage.translatesAutoresizingMaskIntoConstraints = false
        equipmentImage.contentMode = .scaleAspectFill
        equipmentImage.layer.cornerRadius = 10
        equipmentImage.clipsToBounds = true
        equipmentCardView.addSubview(equipmentImage)
        self.imageView = equipmentImage
        
        // Add equipment name
        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.font = UIFont.systemFont(ofSize: 24, weight: .semibold)
        nameLabel.textColor = .darkGray
        equipmentCardView.addSubview(nameLabel)
        self.equipmentNameLabel = nameLabel
        
        // Add price label
        let priceTitle = UILabel()
        priceTitle.translatesAutoresizingMaskIntoConstraints = false
        priceTitle.text = "Price"
        priceTitle.font = UIFont.systemFont(ofSize: 16)
        priceTitle.textColor = .darkGray
        equipmentCardView.addSubview(priceTitle)
        
        let priceValue = UILabel()
        priceValue.translatesAutoresizingMaskIntoConstraints = false
        priceValue.font = UIFont.systemFont(ofSize: 16)
        priceValue.textColor = .darkGray
        equipmentCardView.addSubview(priceValue)
        self.priceLabel = priceValue
        
        // Add hosted by label
        let hostedLabel = UILabel()
        hostedLabel.translatesAutoresizingMaskIntoConstraints = false
        hostedLabel.text = "Hosted By"
        hostedLabel.font = UIFont.systemFont(ofSize: 14)
        hostedLabel.textColor = .darkGray
        equipmentCardView.addSubview(hostedLabel)
        self.hostedByLabel = hostedLabel
        
        // Add view button
        let viewButton = UIButton(type: .system)
        viewButton.translatesAutoresizingMaskIntoConstraints = false
        viewButton.setTitle("View", for: .normal)
        viewButton.setTitleColor(.white, for: .normal)
        viewButton.backgroundColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        viewButton.layer.cornerRadius = 16
        viewButton.addTarget(self, action: #selector(viewButtonTappedAction), for: .touchUpInside)
        equipmentCardView.addSubview(viewButton)
        
        NSLayoutConstraint.activate([
            equipmentImage.topAnchor.constraint(equalTo: equipmentCardView.topAnchor, constant: 16),
            equipmentImage.leadingAnchor.constraint(equalTo: equipmentCardView.leadingAnchor, constant: 16),
            equipmentImage.widthAnchor.constraint(equalToConstant: 90),
            equipmentImage.heightAnchor.constraint(equalToConstant: 90),
            
            nameLabel.topAnchor.constraint(equalTo: equipmentCardView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: equipmentImage.trailingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: equipmentCardView.trailingAnchor, constant: -16),
            
            priceTitle.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceTitle.leadingAnchor.constraint(equalTo: equipmentImage.trailingAnchor, constant: 16),
            
            priceValue.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            priceValue.leadingAnchor.constraint(equalTo: priceTitle.trailingAnchor, constant: 8),
            
            hostedLabel.topAnchor.constraint(equalTo: priceTitle.bottomAnchor, constant: 8),
            hostedLabel.leadingAnchor.constraint(equalTo: equipmentImage.trailingAnchor, constant: 16),
            
            viewButton.trailingAnchor.constraint(equalTo: equipmentCardView.trailingAnchor, constant: -16),
            viewButton.centerYAnchor.constraint(equalTo: equipmentImage.centerYAnchor),
            viewButton.widthAnchor.constraint(equalToConstant: 80),
            viewButton.heightAnchor.constraint(equalToConstant: 40),
            
            equipmentCardView.bottomAnchor.constraint(equalTo: equipmentImage.bottomAnchor, constant: 16)
        ])
    }
    
    private func createImportantDetailsSection() {
        // Add Important Details header
        importantDetailsHeaderLabel = createSectionHeader(title: "Important Details")
        importantDetailsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(importantDetailsHeaderLabel)
        
        NSLayoutConstraint.activate([
            importantDetailsHeaderLabel.topAnchor.constraint(equalTo: equipmentCardView.bottomAnchor, constant: sectionSpacing),
            importantDetailsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            importantDetailsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        // Create Field Area row
        fieldAreaTitleLabel = createRowTitle(title: "Field Area")
        fieldAreaValueLabel = createRowValue()
        addRow(title: fieldAreaTitleLabel, value: fieldAreaValueLabel, below: importantDetailsHeaderLabel)
        
        // Create Status row
        statusTitleLabel = createRowTitle(title: "Status")
        statusValueLabel = createRowValue()
        addRow(title: statusTitleLabel, value: statusValueLabel, below: fieldAreaTitleLabel)
        
        // Create Location row
        locationTitleLabel = createRowTitle(title: "Location")
        locationValueLabel = createRowValue()
        addRow(title: locationTitleLabel, value: locationValueLabel, below: statusTitleLabel)
        
        // Create Time Slot row
        timeSlotTitleLabel = createRowTitle(title: "TimeSlot")
        timeSlotValueLabel = createRowValue()
        addRow(title: timeSlotTitleLabel, value: timeSlotValueLabel, below: locationTitleLabel)
    }
    
    private func createOwnerDetailsSection() {
        // Add Owner Details header
        ownerDetailsHeaderLabel = createSectionHeader(title: "Owner Details")
        ownerDetailsHeaderLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ownerDetailsHeaderLabel)
        
        NSLayoutConstraint.activate([
            ownerDetailsHeaderLabel.topAnchor.constraint(equalTo: timeSlotTitleLabel.bottomAnchor, constant: sectionSpacing),
            ownerDetailsHeaderLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            ownerDetailsHeaderLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding)
        ])
        
        // Create Name row
        nameTitleLabel = createRowTitle(title: "Name")
        nameValueLabel = createRowValue()
        addRow(title: nameTitleLabel, value: nameValueLabel, below: ownerDetailsHeaderLabel)
        
        // Create Mobile row
        mobileTitleLabel = createRowTitle(title: "Mobile")
        mobileValueLabel = createRowValue()
        addRow(title: mobileTitleLabel, value: mobileValueLabel, below: nameTitleLabel)
        self.mobileNoLabel = mobileValueLabel
        
        // Create Rating row with star
        ratingTitleLabel = createRowTitle(title: "Rating")
        
        // Create rating view with star and value
        ratingValueView = UIView()
        ratingValueView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ratingValueView)
        
        let starImageView = UIImageView(image: UIImage(systemName: "star.fill"))
        starImageView.translatesAutoresizingMaskIntoConstraints = false
        starImageView.tintColor = .systemYellow
        starImageView.contentMode = .scaleAspectFit
        ratingValueView.addSubview(starImageView)
        
        ratingValueLabel = UILabel()
        ratingValueLabel.translatesAutoresizingMaskIntoConstraints = false
        ratingValueLabel.font = UIFont.systemFont(ofSize: 16)
        ratingValueLabel.textColor = .darkGray
        ratingValueLabel.textAlignment = .left
        ratingValueView.addSubview(ratingValueLabel)
        self.ratingLabel = ratingValueLabel
        
        NSLayoutConstraint.activate([
            ratingTitleLabel.topAnchor.constraint(equalTo: mobileTitleLabel.bottomAnchor, constant: rowSpacing),
            ratingTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            
            ratingValueView.centerYAnchor.constraint(equalTo: ratingTitleLabel.centerYAnchor),
            ratingValueView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            ratingValueView.heightAnchor.constraint(equalToConstant: 24),
            
            starImageView.leadingAnchor.constraint(equalTo: ratingValueView.leadingAnchor),
            starImageView.centerYAnchor.constraint(equalTo: ratingValueView.centerYAnchor),
            starImageView.widthAnchor.constraint(equalToConstant: 20),
            starImageView.heightAnchor.constraint(equalToConstant: 20),
            
            ratingValueLabel.leadingAnchor.constraint(equalTo: starImageView.trailingAnchor, constant: 4),
            ratingValueLabel.centerYAnchor.constraint(equalTo: ratingValueView.centerYAnchor),
            ratingValueLabel.trailingAnchor.constraint(equalTo: ratingValueView.trailingAnchor)
        ])
    }
    
    private func createCancelButton() {
        cancelButton = UIButton(type: .system)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel Booking", for: .normal)
        cancelButton.setTitleColor(.systemRed, for: .normal)
        cancelButton.backgroundColor = .white
        cancelButton.layer.cornerRadius = 12
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.systemGray4.cgColor
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        cancelButton.addTarget(self, action: #selector(cancelBookingTapped(_:)), for: .touchUpInside)
        
        contentView.addSubview(cancelButton)
        
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: ratingTitleLabel.bottomAnchor, constant: sectionSpacing),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            cancelButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    // MARK: - Helper UI Functions
    
    private func createSectionHeader(title: String) -> UILabel {
        let label = UILabel()
        label.text = title
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .black
        return label
    }
    
    private func createRowTitle(title: String) -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        contentView.addSubview(label)
        return label
    }
    
    private func createRowValue() -> UILabel {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .darkGray
        label.textAlignment = .right
        contentView.addSubview(label)
        return label
    }
    
    private func addRow(title: UILabel, value: UILabel, below topElement: UIView) {
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topElement.bottomAnchor, constant: rowSpacing),
            title.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: horizontalPadding),
            
            value.topAnchor.constraint(equalTo: title.topAnchor),
            value.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -horizontalPadding),
            value.leadingAnchor.constraint(greaterThanOrEqualTo: title.trailingAnchor, constant: 20)
        ])
    }
    
    // MARK: - Data Population
    
    private func populateData() {
        guard let booking = booking, let equipment = equipment else {
            print("Missing booking or equipment data")
            return
        }
        
        // Format date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, dd MMMM"
        dateHeaderLabel.text = dateFormatter.string(from: booking.bookingDate)
        
        // Set equipment image
        if let image = UIImage(named: equipment.equipmentImage) {
            imageView?.image = image
        } else {
            imageView?.image = UIImage(named: "placeholder_equipment")
            print("Warning: Equipment image \(equipment.equipmentImage) not found")
        }
        
        // Set equipment details
        equipmentNameLabel?.text = equipment.name
        priceLabel?.text = "₹ \(Int(equipment.pricePerHour))/hr"
        
        // Set booking details
        fieldAreaValueLabel.text = String(format: "%.1f", booking.fieldArea)
        
        // Set status with appropriate color
        let statusText = booking.status.rawValue.prefix(1).uppercased() + booking.status.rawValue.dropFirst()
        statusValueLabel.text = statusText
        if booking.status == .confirmed {
            statusValueLabel.textColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        } else if booking.status == .pending {
            statusValueLabel.textColor = .systemOrange
        }
        
        // Set location and time slot
        locationValueLabel.text = equipment.location.isEmpty ? "LocationLbl" : equipment.location
        timeSlotValueLabel.text = booking.timeSlot.rawValue
        
        // Set default owner details (will be replaced by actual data if available)
        nameValueLabel.text = "harsh7617..."
        mobileValueLabel.text = "8865830412"
        ratingValueLabel.text = "4.5"
        
        // Fetch provider info from backend
        fetchProviderInfo()
    }
    
    // MARK: - Data Fetching
    
    private func fetchProviderInfo() {
        Task {
            await fetchProviderInfoFromSupabase()
        }
    }
    
    private func fetchProviderInfoFromSupabase() async {
        guard let userId = booking?.userID else {
            print("Error: No user ID available in booking")
            return
        }
        
        print("Fetching provider info for userID: \(userId.uuidString)")
        
        do {
            let result = try await SupabaseManager.shared.client
                .from("users")
                .select("*")
                .eq("userID", value: userId.uuidString)
                .execute()
            
            do {
                let json = try JSONSerialization.jsonObject(with: result.data)
                print("User fetch returned: \(json)")
                
                if let users = json as? [[String: Any]], let user = users.first {
                    // Extract user data
                    let name = user["name"] as? String ?? "harsh7617..."
                    let phone = user["phone"] as? String ?? "8865830412"
                    
                    // Update UI on main thread
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.nameValueLabel.text = name
                        self.mobileValueLabel.text = phone
                        print("✅ Updated provider info: name=\(name), phone=\(phone)")
                    }
                }
            } catch {
                print("❌ Error parsing user data: \(error)")
            }
        } catch {
            print("❌ Error fetching provider info: \(error)")
        }
    }
    
    // MARK: - Actions
    
    @objc private func viewButtonTappedAction() {
        print("Programmatic View button tapped - no action implemented")
        // Here you can implement the same action as the storyboard viewButtonTapped
    }

    @IBAction func viewButtonTapped(_ sender: Any) {
        // This is connected in storyboard
        print("Storyboard View button tapped - no action implemented")
    }
    
    @objc func cancelBookingTapped(_ sender: Any) {
        let alert = UIAlertController(
            title: "Cancel Booking",
            message: "Are you sure you want to cancel this booking?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "No", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { [weak self] _ in
            guard let self = self, let booking = self.booking else { return }
            
            // Update booking status to cancelled
            Task {
                // Create a copy of the booking with updated status
                var updatedBooking = booking
                updatedBooking.status = .pending // Change to cancelled when that status is available
                
                // Try to update the booking in the database
                let success = await self.requestManager.updateBookingStatus(booking.bookingID, status: .pending)
                
                // Update UI on main thread
                await MainActor.run {
                    if success {
                        // Show success message and navigate back
                        let successAlert = UIAlertController(
                            title: "Booking Cancelled",
                            message: "Your booking has been successfully cancelled.",
                            preferredStyle: .alert
                        )
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            self.navigationController?.popViewController(animated: true)
                        })
                        self.present(successAlert, animated: true)
                    } else {
                        // Show error message
                        let errorAlert = UIAlertController(
                            title: "Error",
                            message: "Failed to cancel booking. Please try again later.",
                            preferredStyle: .alert
                        )
                        errorAlert.addAction(UIAlertAction(title: "OK", style: .default))
                        self.present(errorAlert, animated: true)
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
}

