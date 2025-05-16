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
    
    // MARK: - Initializers
    init(equipment: Equipment, booking: Booking) {
        super.init(nibName: nil, bundle: nil)
        self.equipment = equipment
        self.booking = booking
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // This initializer is required but won't be used anymore
    }
    private let requestManager = RequestManager.shared
    
    // Colors according to Apple Design Guidelines
    private let primaryColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
    private let secondaryColor = UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1)
    private let accentColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
    private let textPrimaryColor = UIColor.darkText
    private let textSecondaryColor = UIColor.darkGray
    private let backgroundColor = UIColor.systemBackground
    private let cardBackgroundColor = UIColor.secondarySystemBackground
    
    // MARK: - UI Elements Declaration
    
    // MARK: - UI Elements (Programmatic)
    // Scroll view for content
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    // Equipment Card
    private let programmaticEquipmentCardView = UIView()
    private let programmaticImageView = UIImageView()
    private let programmaticEquipmentNameLabel = UILabel()
    private let programmaticPriceLabel = UILabel()
    private let programmaticRatingLabel = UILabel()
    private let programmaticStatusLabel = UILabel()
    
    // Booking Details Card
    private let programmaticBookingDetailsCardView = UIView()
    private let programmaticDateLabel = UILabel()
    private let programmaticTimeSlotLabel = UILabel()
    private let programmaticFieldAreaLabel = UILabel()
    private let programmaticLocationLabel = UILabel()
    
    // Provider Card
    private let programmaticProviderCardView = UIView()
    private let programmaticHostedByLabel = UILabel()
    private let programmaticProviderNameLabel = UILabel()
    private let programmaticMobileNoLabel = UILabel()
    
    // Action Buttons
    private let viewButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("BookingDetailsViewController - viewDidLoad called")
        if let equipment = equipment, let booking = booking {
            print("BookingDetailsViewController - Equipment: \(equipment.name), Booking ID: \(booking.bookingID)")
        }
        
        // Setup UI
        setupUI()
        
        // Populate UI with data
        populateUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Apply dynamic text sizing for accessibility
        updateFontsForAccessibility()
    }
    
    // MARK: - UI Setup
    
    private func setupUI() {
        // Setup base view
        view.backgroundColor = backgroundColor
        
        // Setup navigation bar
        setupNavigationBar()
        
        // Setup scroll view and content view
        setupScrollView()
        
        // Setup UI cards
        setupEquipmentCard()
        setupBookingDetailsCard()
        setupProviderCard()
        setupActionButtons()
        
        // Setup constraints
        setupConstraints()
        
        // Setup accessibility
        setupAccessibility()
        
        // Update fonts for accessibility
        updateFontsForAccessibility()
    }
    

    private func setupNavigationBar() {
        // Configure navigation bar with modern appearance
        navigationController?.navigationBar.tintColor = primaryColor
        navigationController?.navigationBar.topItem?.backButtonTitle = "Back"
        
        // Set title with appropriate style
        title = "Booking Details"
        navigationController?.navigationBar.prefersLargeTitles = false
        
        // Add subtle shadow to navigation bar for depth
        navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 1)
        navigationController?.navigationBar.layer.shadowRadius = 2
        navigationController?.navigationBar.layer.shadowOpacity = 0.1
    }
    
    private func setupScrollView() {
        // Configure scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Enable scroll indicators
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        
        // Set scroll view constraints
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
    }
    
    private func setupEquipmentCard() {
        // Configure equipment card view
        programmaticEquipmentCardView.translatesAutoresizingMaskIntoConstraints = false
        programmaticEquipmentCardView.backgroundColor = cardBackgroundColor
        programmaticEquipmentCardView.layer.cornerRadius = 12
        programmaticEquipmentCardView.layer.shadowColor = UIColor.black.cgColor
        programmaticEquipmentCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        programmaticEquipmentCardView.layer.shadowRadius = 6
        programmaticEquipmentCardView.layer.shadowOpacity = 0.1
        programmaticEquipmentCardView.clipsToBounds = false
        
        // Add equipment card to content view
        contentView.addSubview(programmaticEquipmentCardView)
        
        // Configure image view
        programmaticImageView.translatesAutoresizingMaskIntoConstraints = false
        programmaticImageView.contentMode = .scaleAspectFill
        programmaticImageView.layer.cornerRadius = 8
        programmaticImageView.clipsToBounds = true
        programmaticImageView.backgroundColor = .systemGray6
        programmaticEquipmentCardView.addSubview(programmaticImageView)
        
        // Configure equipment name label
        programmaticEquipmentNameLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticEquipmentNameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        programmaticEquipmentNameLabel.textColor = textPrimaryColor
        programmaticEquipmentNameLabel.numberOfLines = 0
        programmaticEquipmentCardView.addSubview(programmaticEquipmentNameLabel)
        
        // Configure price label
        programmaticPriceLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticPriceLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        programmaticPriceLabel.textColor = accentColor
        programmaticEquipmentCardView.addSubview(programmaticPriceLabel)
        
        // Configure rating label
        programmaticRatingLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticRatingLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        programmaticRatingLabel.textColor = .systemYellow
        programmaticEquipmentCardView.addSubview(programmaticRatingLabel)
        
        // Configure status label
        programmaticStatusLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticStatusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        programmaticStatusLabel.textAlignment = .center
        programmaticStatusLabel.layer.cornerRadius = 12
        programmaticStatusLabel.clipsToBounds = true
        programmaticStatusLabel.backgroundColor = UIColor.systemGray6
        programmaticStatusLabel.textColor = textPrimaryColor
        programmaticEquipmentCardView.addSubview(programmaticStatusLabel)
    }
    
    private func setupBookingDetailsCard() {
        // Configure booking details card view
        programmaticBookingDetailsCardView.translatesAutoresizingMaskIntoConstraints = false
        programmaticBookingDetailsCardView.backgroundColor = cardBackgroundColor
        programmaticBookingDetailsCardView.layer.cornerRadius = 12
        programmaticBookingDetailsCardView.layer.shadowColor = UIColor.black.cgColor
        programmaticBookingDetailsCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        programmaticBookingDetailsCardView.layer.shadowRadius = 6
        programmaticBookingDetailsCardView.layer.shadowOpacity = 0.1
        programmaticBookingDetailsCardView.clipsToBounds = false
        
        // Add booking details card to content view
        contentView.addSubview(programmaticBookingDetailsCardView)
        
        // Configure date label
        programmaticDateLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticDateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        programmaticDateLabel.textColor = textPrimaryColor
        programmaticDateLabel.numberOfLines = 0
        programmaticBookingDetailsCardView.addSubview(programmaticDateLabel)
        
        // Configure time slot label
        programmaticTimeSlotLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticTimeSlotLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        programmaticTimeSlotLabel.textColor = textSecondaryColor
        programmaticTimeSlotLabel.numberOfLines = 0
        programmaticBookingDetailsCardView.addSubview(programmaticTimeSlotLabel)
        
        // Configure field area label
        programmaticFieldAreaLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticFieldAreaLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        programmaticFieldAreaLabel.textColor = textSecondaryColor
        programmaticFieldAreaLabel.numberOfLines = 0
        programmaticBookingDetailsCardView.addSubview(programmaticFieldAreaLabel)
        
        // Configure location label
        programmaticLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticLocationLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        programmaticLocationLabel.textColor = textSecondaryColor
        programmaticLocationLabel.numberOfLines = 0
        programmaticBookingDetailsCardView.addSubview(programmaticLocationLabel)
    }
    
    private func setupProviderCard() {
        // Configure provider card view
        programmaticProviderCardView.translatesAutoresizingMaskIntoConstraints = false
        programmaticProviderCardView.backgroundColor = cardBackgroundColor
        programmaticProviderCardView.layer.cornerRadius = 12
        programmaticProviderCardView.layer.shadowColor = UIColor.black.cgColor
        programmaticProviderCardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        programmaticProviderCardView.layer.shadowRadius = 6
        programmaticProviderCardView.layer.shadowOpacity = 0.1
        programmaticProviderCardView.clipsToBounds = false
        
        // Add provider card to content view
        contentView.addSubview(programmaticProviderCardView)
        
        // Configure hosted by label
        programmaticHostedByLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticHostedByLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        programmaticHostedByLabel.text = "Provider Details"
        programmaticHostedByLabel.textColor = textPrimaryColor
        programmaticProviderCardView.addSubview(programmaticHostedByLabel)
        
        // Configure provider name label
        programmaticProviderNameLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticProviderNameLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        programmaticProviderNameLabel.textColor = textSecondaryColor
        programmaticProviderNameLabel.numberOfLines = 0
        programmaticProviderCardView.addSubview(programmaticProviderNameLabel)
        
        // Configure mobile number label
        programmaticMobileNoLabel.translatesAutoresizingMaskIntoConstraints = false
        programmaticMobileNoLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        programmaticMobileNoLabel.textColor = textSecondaryColor
        programmaticMobileNoLabel.numberOfLines = 0
        programmaticProviderCardView.addSubview(programmaticMobileNoLabel)
    }
    
    private func setupActionButtons() {
        // Configure view button
        viewButton.translatesAutoresizingMaskIntoConstraints = false
        viewButton.setTitle("View Equipment", for: .normal)
        viewButton.setTitleColor(.white, for: .normal)
        viewButton.backgroundColor = primaryColor
        viewButton.layer.cornerRadius = 8
        viewButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        viewButton.addTarget(self, action: #selector(viewButtonTapped(_:)), for: .touchUpInside)
        contentView.addSubview(viewButton)
        
        // Configure cancel button
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        cancelButton.setTitle("Cancel Booking", for: .normal)
        cancelButton.setTitleColor(primaryColor, for: .normal)
        cancelButton.backgroundColor = .clear
        cancelButton.layer.cornerRadius = 8
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = primaryColor.cgColor
        cancelButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        cancelButton.addTarget(self, action: #selector(cancelBookingTapped(_:)), for: .touchUpInside)
        contentView.addSubview(cancelButton)
    }
    
    private func setupAccessibility() {
        // Make UI elements accessible
        programmaticImageView.isAccessibilityElement = true
        programmaticImageView.accessibilityLabel = "Equipment image"
        
        // Enable dynamic type for all labels
        [programmaticEquipmentNameLabel, programmaticDateLabel, programmaticPriceLabel, programmaticProviderNameLabel, 
         programmaticMobileNoLabel, programmaticRatingLabel, programmaticFieldAreaLabel, programmaticLocationLabel, 
         programmaticTimeSlotLabel, programmaticStatusLabel, programmaticHostedByLabel].forEach { label in
            label.adjustsFontForContentSizeCategory = true
            label.setContentCompressionResistancePriority(.required, for: .vertical)
            label.setContentHuggingPriority(.required, for: .vertical)
        }
    }
    
    private func setupConstraints() {
        // Set padding constants
        let padding: CGFloat = 16
        let cardSpacing: CGFloat = 16
        let innerPadding: CGFloat = 12
        
        // Equipment Card Constraints
        NSLayoutConstraint.activate([
            programmaticEquipmentCardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            programmaticEquipmentCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            programmaticEquipmentCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            programmaticImageView.topAnchor.constraint(equalTo: programmaticEquipmentCardView.topAnchor, constant: innerPadding),
            programmaticImageView.leadingAnchor.constraint(equalTo: programmaticEquipmentCardView.leadingAnchor, constant: innerPadding),
            programmaticImageView.widthAnchor.constraint(equalToConstant: 100),
            programmaticImageView.heightAnchor.constraint(equalToConstant: 100),
            
            programmaticStatusLabel.topAnchor.constraint(equalTo: programmaticEquipmentCardView.topAnchor, constant: innerPadding),
            programmaticStatusLabel.trailingAnchor.constraint(equalTo: programmaticEquipmentCardView.trailingAnchor, constant: -innerPadding),
            programmaticStatusLabel.heightAnchor.constraint(equalToConstant: 24),
            programmaticStatusLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80),
            
            programmaticEquipmentNameLabel.topAnchor.constraint(equalTo: programmaticEquipmentCardView.topAnchor, constant: innerPadding),
            programmaticEquipmentNameLabel.leadingAnchor.constraint(equalTo: programmaticImageView.trailingAnchor, constant: innerPadding),
            programmaticEquipmentNameLabel.trailingAnchor.constraint(equalTo: programmaticStatusLabel.leadingAnchor, constant: -innerPadding),
            
            programmaticPriceLabel.topAnchor.constraint(equalTo: programmaticEquipmentNameLabel.bottomAnchor, constant: 8),
            programmaticPriceLabel.leadingAnchor.constraint(equalTo: programmaticImageView.trailingAnchor, constant: innerPadding),
            programmaticPriceLabel.trailingAnchor.constraint(equalTo: programmaticEquipmentCardView.trailingAnchor, constant: -innerPadding),
            
            programmaticRatingLabel.topAnchor.constraint(equalTo: programmaticPriceLabel.bottomAnchor, constant: 8),
            programmaticRatingLabel.leadingAnchor.constraint(equalTo: programmaticImageView.trailingAnchor, constant: innerPadding),
            programmaticRatingLabel.trailingAnchor.constraint(equalTo: programmaticEquipmentCardView.trailingAnchor, constant: -innerPadding),
            programmaticRatingLabel.bottomAnchor.constraint(lessThanOrEqualTo: programmaticEquipmentCardView.bottomAnchor, constant: -innerPadding),
            
            programmaticImageView.bottomAnchor.constraint(lessThanOrEqualTo: programmaticEquipmentCardView.bottomAnchor, constant: -innerPadding),
            programmaticEquipmentCardView.bottomAnchor.constraint(greaterThanOrEqualTo: programmaticImageView.bottomAnchor, constant: innerPadding)
        ])
        
        // Booking Details Card Constraints
        NSLayoutConstraint.activate([
            programmaticBookingDetailsCardView.topAnchor.constraint(equalTo: programmaticEquipmentCardView.bottomAnchor, constant: cardSpacing),
            programmaticBookingDetailsCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            programmaticBookingDetailsCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            programmaticDateLabel.topAnchor.constraint(equalTo: programmaticBookingDetailsCardView.topAnchor, constant: innerPadding),
            programmaticDateLabel.leadingAnchor.constraint(equalTo: programmaticBookingDetailsCardView.leadingAnchor, constant: innerPadding),
            programmaticDateLabel.trailingAnchor.constraint(equalTo: programmaticBookingDetailsCardView.trailingAnchor, constant: -innerPadding),
            
            programmaticTimeSlotLabel.topAnchor.constraint(equalTo: programmaticDateLabel.bottomAnchor, constant: 8),
            programmaticTimeSlotLabel.leadingAnchor.constraint(equalTo: programmaticBookingDetailsCardView.leadingAnchor, constant: innerPadding),
            programmaticTimeSlotLabel.trailingAnchor.constraint(equalTo: programmaticBookingDetailsCardView.trailingAnchor, constant: -innerPadding),
            
            programmaticFieldAreaLabel.topAnchor.constraint(equalTo: programmaticTimeSlotLabel.bottomAnchor, constant: 8),
            programmaticFieldAreaLabel.leadingAnchor.constraint(equalTo: programmaticBookingDetailsCardView.leadingAnchor, constant: innerPadding),
            programmaticFieldAreaLabel.trailingAnchor.constraint(equalTo: programmaticBookingDetailsCardView.trailingAnchor, constant: -innerPadding),
            
            programmaticLocationLabel.topAnchor.constraint(equalTo: programmaticFieldAreaLabel.bottomAnchor, constant: 8),
            programmaticLocationLabel.leadingAnchor.constraint(equalTo: programmaticBookingDetailsCardView.leadingAnchor, constant: innerPadding),
            programmaticLocationLabel.trailingAnchor.constraint(equalTo: programmaticBookingDetailsCardView.trailingAnchor, constant: -innerPadding),
            programmaticLocationLabel.bottomAnchor.constraint(equalTo: programmaticBookingDetailsCardView.bottomAnchor, constant: -innerPadding)
        ])
        
        // Provider Card Constraints
        NSLayoutConstraint.activate([
            programmaticProviderCardView.topAnchor.constraint(equalTo: programmaticBookingDetailsCardView.bottomAnchor, constant: cardSpacing),
            programmaticProviderCardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            programmaticProviderCardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            
            programmaticHostedByLabel.topAnchor.constraint(equalTo: programmaticProviderCardView.topAnchor, constant: innerPadding),
            programmaticHostedByLabel.leadingAnchor.constraint(equalTo: programmaticProviderCardView.leadingAnchor, constant: innerPadding),
            programmaticHostedByLabel.trailingAnchor.constraint(equalTo: programmaticProviderCardView.trailingAnchor, constant: -innerPadding),
            
            programmaticProviderNameLabel.topAnchor.constraint(equalTo: programmaticHostedByLabel.bottomAnchor, constant: 8),
            programmaticProviderNameLabel.leadingAnchor.constraint(equalTo: programmaticProviderCardView.leadingAnchor, constant: innerPadding),
            programmaticProviderNameLabel.trailingAnchor.constraint(equalTo: programmaticProviderCardView.trailingAnchor, constant: -innerPadding),
            
            programmaticMobileNoLabel.topAnchor.constraint(equalTo: programmaticProviderNameLabel.bottomAnchor, constant: 8),
            programmaticMobileNoLabel.leadingAnchor.constraint(equalTo: programmaticProviderCardView.leadingAnchor, constant: innerPadding),
            programmaticMobileNoLabel.trailingAnchor.constraint(equalTo: programmaticProviderCardView.trailingAnchor, constant: -innerPadding),
            programmaticMobileNoLabel.bottomAnchor.constraint(equalTo: programmaticProviderCardView.bottomAnchor, constant: -innerPadding)
        ])
        
        // Action Buttons Constraints
        NSLayoutConstraint.activate([
            viewButton.topAnchor.constraint(equalTo: programmaticProviderCardView.bottomAnchor, constant: cardSpacing),
            viewButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            viewButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            viewButton.heightAnchor.constraint(equalToConstant: 50),
            
            cancelButton.topAnchor.constraint(equalTo: viewButton.bottomAnchor, constant: innerPadding),
            cancelButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            cancelButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }
    
    private func updateFontsForAccessibility() {
        // Apply semantic text styles that adapt to user's preferred text size
        programmaticEquipmentNameLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        programmaticDateLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        programmaticPriceLabel.font = UIFont.preferredFont(forTextStyle: .headline)
        programmaticProviderNameLabel.font = UIFont.preferredFont(forTextStyle: .body)
        programmaticMobileNoLabel.font = UIFont.preferredFont(forTextStyle: .body)
        programmaticRatingLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        programmaticFieldAreaLabel.font = UIFont.preferredFont(forTextStyle: .body)
        programmaticLocationLabel.font = UIFont.preferredFont(forTextStyle: .body)
        programmaticTimeSlotLabel.font = UIFont.preferredFont(forTextStyle: .body)
        programmaticHostedByLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        
        // Ensure labels adjust their height to fit content
        [programmaticEquipmentNameLabel, programmaticDateLabel, programmaticPriceLabel, programmaticProviderNameLabel, 
         programmaticMobileNoLabel, programmaticRatingLabel, programmaticFieldAreaLabel, programmaticLocationLabel, 
         programmaticTimeSlotLabel, programmaticStatusLabel, programmaticHostedByLabel].forEach { label in
            label.numberOfLines = 0 // Allow multiple lines
            label.lineBreakMode = .byWordWrapping
            label.minimumScaleFactor = 0.8
            label.adjustsFontSizeToFitWidth = true
        }
    }
    
    private func populateUI() {
        // Populate UI elements with data
        guard let booking = booking, let equipment = equipment else {
            print("Missing booking or equipment data")
            return
        }
        
        // Set equipment image with smooth transition
        if equipment.equipmentImage.hasPrefix("http") {
            // It's a URL, use our ImageCache utility to load it
            programmaticImageView.image = UIImage(named: "placeholder_equipment") // Start with placeholder
            
            // Load the image asynchronously
            ImageCache.shared.loadImage(from: equipment.equipmentImage) { [weak self] image in
                guard let self = self, let downloadedImage = image else { return }
                
                // Apply smooth transition when image is loaded
                DispatchQueue.main.async {
                    UIView.transition(with: self.programmaticImageView,
                                  duration: 0.3,
                                  options: .transitionCrossDissolve,
                                  animations: { self.programmaticImageView.image = downloadedImage },
                                  completion: nil)
                }
            }
        } else if let image = UIImage(named: equipment.equipmentImage) {
            // Local asset image
            UIView.transition(with: programmaticImageView,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: { self.programmaticImageView.image = image },
                              completion: nil)
        } else {
            // Use placeholder image if the specified image isn't found
            programmaticImageView.image = UIImage(named: "placeholder_equipment")
            print("Warning: Equipment image \(equipment.equipmentImage) not found")
        }
        
        // Set equipment details with proper styling
        programmaticEquipmentNameLabel.text = equipment.name
        programmaticEquipmentNameLabel.textColor = textPrimaryColor
        
        // Format price with currency symbol and proper spacing
        programmaticPriceLabel.text = "₹ \(Int(equipment.pricePerHour))/hr"
        programmaticPriceLabel.textColor = accentColor
        
        // Format and set booking date with locale-aware formatting
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        programmaticDateLabel.text = "Date: " + dateFormatter.string(from: booking.bookingDate)
        programmaticDateLabel.textColor = textPrimaryColor
        
        // Set booking details with proper units
        programmaticFieldAreaLabel.text = "Field Area: " + String(format: "%.1f acres", booking.fieldArea)
        programmaticFieldAreaLabel.textColor = textSecondaryColor
        
        // Set status with modern pill/badge styling
        let statusText = booking.status.rawValue.prefix(1).uppercased() + booking.status.rawValue.dropFirst()
        programmaticStatusLabel.text = statusText
        
        // Apply status-specific styling
        if booking.status == .confirmed {
            programmaticStatusLabel.backgroundColor = primaryColor.withAlphaComponent(0.2)
            programmaticStatusLabel.textColor = primaryColor
        } else if booking.status == .pending {
            programmaticStatusLabel.backgroundColor = UIColor.systemOrange.withAlphaComponent(0.2)
            programmaticStatusLabel.textColor = .systemOrange
        }
        
        // Set location with icon prefix and proper formatting
        programmaticLocationLabel.text = "Location: " + (equipment.location.isEmpty ? "Not specified" : equipment.location)
        programmaticLocationLabel.textColor = textSecondaryColor
        
        // Set time slot with icon prefix
        programmaticTimeSlotLabel.text = "Time: " + booking.timeSlot.rawValue
        programmaticTimeSlotLabel.textColor = textSecondaryColor
        
        // Set provider info with loading state and proper styling
        programmaticProviderNameLabel.text = "Loading..."
        programmaticProviderNameLabel.textColor = .tertiaryLabel
        programmaticMobileNoLabel.text = "Loading..."
        programmaticMobileNoLabel.textColor = .tertiaryLabel
        
        // Set rating with star symbol and proper color
        if equipment.rating > 0 {
            programmaticRatingLabel.text = "★ " + String(format: "%.1f", equipment.rating)
            programmaticRatingLabel.textColor = .systemYellow
        } else {
            programmaticRatingLabel.text = "No ratings yet"
            programmaticRatingLabel.textColor = .secondaryLabel
        }
        
        // Apply proper styling to hosted by label
        programmaticHostedByLabel.textColor = textPrimaryColor
        programmaticHostedByLabel.text = "Provider Details"
        
        // Fetch provider info from backend
        fetchProviderInfo()
    }
    
    // MARK: - Data Fetching
    
    private func fetchProviderInfo() {
        Task {
            guard let booking = booking, let equipment = equipment else {
                print("Error: No booking or equipment data available")
                return
            }
            
            // Show loading state with animation
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                
                // Apply loading state styling
                UIView.animate(withDuration: 0.3) {
                    self.programmaticProviderNameLabel.textColor = .tertiaryLabel
                    self.programmaticMobileNoLabel.textColor = .tertiaryLabel
                    
                    // Add subtle pulse animation to indicate loading
                    self.programmaticProviderNameLabel.alpha = 0.7
                    self.programmaticMobileNoLabel.alpha = 0.7
                }
            }
            
            // Get provider ID from equipment
            let providerID = equipment.providerID
            print("Fetching provider info for providerID: \(providerID.uuidString)")
            
            do {
                // Try to fetch from users table using the providerID
                let result = try await SupabaseManager.shared.client
                    .from("users")
                    .select("*")
                    .eq("userID", value: providerID.uuidString)
                    .execute()
                
                do {
                    let json = try JSONSerialization.jsonObject(with: result.data)
                    print("Provider fetch returned: \(json)")
                    
                    if let users = json as? [[String: Any]], let user = users.first {
                        // Extract provider data
                        let name = user["name"] as? String ?? "Provider"
                        let phone = user["phone"] as? String ?? "Not available"
                        
                        // Save to equipment object for future reference
                        self.equipment?.providerName = name
                        
                        // Update UI on main thread with smooth transition
                        await MainActor.run { [weak self] in
                            guard let self = self else { return }
                            self.updateProviderLabels(name: name, phone: phone)
                        }
                    } else {
                        // If no user found in users table, try the providers table
                        let providerResult = try await SupabaseManager.shared.client
                            .from("providers")
                            .select("*")
                            .eq("providerID", value: providerID.uuidString)
                            .execute()
                        
                        let providerJson = try JSONSerialization.jsonObject(with: providerResult.data)
                        print("Provider table fetch returned: \(providerJson)")
                        
                        if let providers = providerJson as? [[String: Any]], let provider = providers.first {
                            // Extract provider data from providers table
                            let name = provider["name"] as? String ?? "Provider"
                            let phone = provider["contactNumber"] as? String ?? provider["phone"] as? String ?? "Not available"
                            
                            // Save to equipment object for future reference
                            self.equipment?.providerName = name
                            
                            // Update UI on main thread with smooth transition
                            await MainActor.run { [weak self] in
                                guard let self = self else { return }
                                self.updateProviderLabels(name: name, phone: phone)
                            }
                        } else {
                            await MainActor.run { [weak self] in
                                guard let self = self else { return }
                                self.updateProviderLabelsWithFallback()
                            }
                        }
                    }
                } catch {
                    print("❌ Error parsing provider data: \(error)")
                    await MainActor.run { [weak self] in
                        guard let self = self else { return }
                        self.updateProviderLabelsWithFallback()
                    }
                }
            } catch {
                print("❌ Error fetching provider info: \(error)")
                await MainActor.run { [weak self] in
                    guard let self = self else { return }
                    self.updateProviderLabelsWithFallback()
                }
            }
        }
    }
    
    private func updateProviderLabels(name: String, phone: String) {
        // Animate the text change for a smoother experience
        UIView.transition(with: programmaticProviderNameLabel, 
                          duration: 0.4, 
                          options: .transitionCrossDissolve, 
                          animations: { [weak self] in
            guard let self = self else { return }
            self.programmaticProviderNameLabel.text = "Name: " + name
            self.programmaticProviderNameLabel.textColor = self.textPrimaryColor
            self.programmaticProviderNameLabel.alpha = 1.0
        }, completion: nil)
        
        UIView.transition(with: programmaticMobileNoLabel, 
                          duration: 0.4, 
                          options: .transitionCrossDissolve, 
                          animations: { [weak self] in
            guard let self = self else { return }
            self.programmaticMobileNoLabel.text = "Phone: " + phone
            self.programmaticMobileNoLabel.textColor = self.textSecondaryColor
            self.programmaticMobileNoLabel.alpha = 1.0
        }, completion: nil)
        
        print("✅ Updated provider info: name=\(name), phone=\(phone)")
    }
    
    private func updateProviderLabelsWithFallback() {
        // Update provider labels with fallback values and proper styling
        updateProviderLabels(name: "Provider", phone: "Not available")
    }
    
    // MARK: - Actions

    @objc private func viewButtonTapped(_ sender: Any) {
        // Handle view button tap
        print("View button tapped - no action implemented")
        
        // Add haptic feedback for button press
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    @objc private func cancelBookingTapped(_ sender: Any) {
        // Add haptic feedback for button press
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // Create modern alert with clear messaging
        let alert = UIAlertController(
            title: "Cancel Booking",
            message: "Are you sure you want to cancel this booking?",
            preferredStyle: .alert
        )
        
        // Style the alert actions
        alert.addAction(UIAlertAction(title: "No, Keep Booking", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes, Cancel", style: .destructive) { [weak self] _ in
            guard let self = self, let booking = self.booking else { return }
            
            // Show loading indicator with modern styling
            let loadingAlert = UIAlertController(title: nil, message: "Cancelling booking...", preferredStyle: .alert)
            
            // Create and configure activity indicator
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .medium
            loadingIndicator.startAnimating()
            
            // Center the activity indicator in the alert
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            container.addSubview(loadingIndicator)
            loadingIndicator.center = container.center
            loadingAlert.view.addSubview(container)
            container.center = CGPoint(x: loadingAlert.view.bounds.midX, y: loadingAlert.view.bounds.midY - 10)
            
            self.present(loadingAlert, animated: true)
            
            // Cancel the booking in the database
            Task {
                var deletionSuccessful = false
                var errorMessage = "An unknown error occurred while canceling your booking."
                
                do {
                    // Delete the booking record completely as requested
                    let response = try await SupabaseManager.shared.client
                        .from("bookings")
                        .delete()
                        .eq("bookingID", value: booking.bookingID.uuidString)
                        .execute()
                    
                    // Check if the deletion was successful by verifying the response
                    let data = response.data
                    if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                       !jsonArray.isEmpty {
                        // If we got a non-empty response, the deletion was successful
                        deletionSuccessful = true
                        print("Booking deletion successful with response: \(jsonArray)")
                    } else {
                        // Empty response might indicate no records were found/deleted
                        errorMessage = "Could not find the booking to cancel. It may have already been removed."
                        print("Booking deletion returned empty response - no records found/deleted")
                    }
                } catch {
                    errorMessage = "Error: \(error.localizedDescription)"
                    print("Error during booking deletion API call: \(error)")
                }
                
                // Show appropriate message based on actual deletion result
                await MainActor.run {
                    // Dismiss loading alert
                    loadingAlert.dismiss(animated: true) {
                        if deletionSuccessful {
                            // Add success haptic feedback
                            let successGenerator = UINotificationFeedbackGenerator()
                            successGenerator.notificationOccurred(.success)
                            
                            // Show success message with clear action
                            let successAlert = UIAlertController(
                                title: "Booking Cancelled",
                                message: "Your booking has been successfully cancelled.",
                                preferredStyle: .alert
                            )
                            successAlert.addAction(UIAlertAction(title: "Return to Bookings", style: .default) { _ in
                                // Post notification to refresh bookings list
                                NotificationCenter.default.post(name: NSNotification.Name("RefreshBookingsList"), object: nil)
                                
                                // Return to previous screen
                                self.navigationController?.popViewController(animated: true)
                            })
                            self.present(successAlert, animated: true)
                        } else {
                            // Add error haptic feedback
                            let errorGenerator = UINotificationFeedbackGenerator()
                            errorGenerator.notificationOccurred(.error)
                            
                            // Show error message
                            let errorAlert = UIAlertController(
                                title: "Cancellation Failed",
                                message: errorMessage,
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "Try Again", style: .default))
                            errorAlert.addAction(UIAlertAction(title: "Return to Bookings", style: .default) { _ in
                                // Return to previous screen
                                self.navigationController?.popViewController(animated: true)
                            })
                            self.present(errorAlert, animated: true)
                        }
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
}
