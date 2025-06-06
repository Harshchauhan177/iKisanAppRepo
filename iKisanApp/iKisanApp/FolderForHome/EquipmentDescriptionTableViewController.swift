//
//  EquipmentDescriptionTableViewController.swift
//  iKisanApp
//
//  Created by ANSHU NAGAR on 18/01/25.
//

import UIKit

class EquipmentDescriptionTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: Section1 Equipment Deatils
    
    var bookingSource: BookingSource!
    
    var equipment: Equipment? {
        didSet {
            if isViewLoaded, let equipment = equipment {
                configure(with: equipment)
            }
        }
    }
    var equipmentName : String? = nil
    var discountedPriceHr : String?
    var realPriceHr: String?
    var discountedPriceAc: String?
    var realPriceAc: String?
    var coEquipDetail: String?
    var location: String? = "Atta"
    var rating: String?
    var providerName: String? = nil
    var bigImage : String?
    var smallImage1: String?
    var smallImage2: String?
    var smallImage3: String?
    var more: String = "More"
    var ratingOutOf5: String?
    var equipmentLocationDetailed: String?
    var model: String?
    var capacity: String?
    var mileage: String?
    var moreImages: [String] = []
    var selectedDate: Date?
    
    
    //Outlet for View(for Radius )
    
    @IBOutlet var bigView: UIView!
    
    @IBOutlet var ratingView: UIView!
    
    
    @IBOutlet var moreView: UIView!
    
    @IBOutlet var hostedByLabel: UILabel!
    @IBOutlet var equipmentNameLabel: UILabel!
    @IBOutlet var discountedPriceHrLabel: UILabel!
    @IBOutlet var realPriceHrLabel: UILabel!
    @IBOutlet var discountedPriceAcLabel: UILabel!
    @IBOutlet var realPriceAcLabel: UILabel!
    @IBOutlet var coEquipDetailLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
    //MARK: Photos - Images & labels Outlets
    
    @IBOutlet var bigImageView: UIImageView!
    @IBOutlet var smallImageView1: UIImageView!
    @IBOutlet var smallImageView2: UIImageView!
    @IBOutlet var smallImageView3: UIImageView!
    
    @IBOutlet var moreLabel: UILabel!
    
    //MARK: Section Rating & Reviews
    
    
    @IBOutlet var ratingOutOf5Label: UILabel!
    
    
    //MARK: Collection View
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //MARK: Equipment's Location Row
    
    
    @IBOutlet var equipmentLocationDetailedLabel: UILabel!
    
    
    //MARK: More Details Row
    
    
    @IBOutlet var modelLabel: UILabel!
    
    @IBOutlet var capacityLabel: UILabel!
    
    
    @IBOutlet var mileageLabel: UILabel!
    
    // MARK: Review Section UI Elements
    private var reviewsSection: UITableViewCell?
    private var noReviewsView: NoReviewsView?
    private var reviewsHeaderView: ReviewsHeaderView?
    
    private var reviews: [ReviewData] = []
    private var dataController: DataController?
    private var filteredReviews: [ReviewData] = []
    private var userCanWriteReview: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupReviewsSection()
        if let equipment = equipment {
            configure(with: equipment)
        }
        
        // Initialize dataController if needed
        dataController = IKisanDataController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Refresh reviews when view appears
        if let equipment = equipment {
            // Add test review for debugging - remove in production
            if equipment.name == "Square Balers" {
                print("Adding test review for Square Balers")
                let testReview = ReviewData(
                    reviewHeading: "Great equipment",
                    reviewDescription: "Works perfectly for my farm",
                    rating: 4.5,
                    equipmentID: equipment.equipmentID.uuidString,
                    equipmentName: equipment.name
                )
                ReviewDataClass.reviews.append(testReview)
            }
            
            refreshReviews(for: equipment)
            checkUserBookingStatus(for: equipment)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Make sure our review section views have the correct size
        if let reviewsCell = reviewsSection {
            if filteredReviews.isEmpty {
                noReviewsView?.frame = CGRect(x: 0, y: 0, width: reviewsCell.contentView.bounds.width, height: 200)
            } else {
                reviewsHeaderView?.frame = CGRect(x: 0, y: 0, width: reviewsCell.contentView.bounds.width, height: 100)
                collectionView.frame = CGRect(x: 0, y: 100, width: reviewsCell.contentView.bounds.width, height: 180)
            }
        }
    }
    
    private func setupUI() {
        // Safe unwrapping of UIView components to apply styling
        if let bView = bigView {
            bView.layer.cornerRadius = 10
            bView.applyCardShadow()
        }
        
        if let rView = ratingView {
            rView.layer.cornerRadius = 17
            //ratingView.applyCardShadow()
        }
        
        // Safe unwrapping of UIImageViews to set corner radius
        if let bigImg = bigImageView {
            bigImg.layer.cornerRadius = 10
        }
        
        if let smallImg1 = smallImageView1 {
            smallImg1.layer.cornerRadius = 10
        }
        
        if let smallImg2 = smallImageView2 {
            smallImg2.layer.cornerRadius = 10
        }
        
        if let smallImg3 = smallImageView3 {
            smallImg3.layer.cornerRadius = 10
        }
        
        if let mView = moreView {
            mView.layer.cornerRadius = 10
        }
        
        // Configure Dynamic Text for all labels
        configureForDynamicType()
        
        // Configure collection view
        if let collectionView = collectionView {
            collectionView.delegate = self
            collectionView.dataSource = self
            
            // Create a layout for horizontal scrolling
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
            collectionView.collectionViewLayout = layout
            
            // Make sure collection view has proper styling
            collectionView.backgroundColor = .systemBackground
            collectionView.showsHorizontalScrollIndicator = false
            collectionView.isPagingEnabled = false
            collectionView.alwaysBounceHorizontal = true
        }
    }
    
    // Configure Dynamic Text support for all labels
    private func configureForDynamicType() {
        // Register for content size category changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
        
        // Apply dynamic text settings to all labels
        setDynamicTextStyles()
    }
    
    private func setDynamicTextStyles() {
        // Map of labels to their base font sizes and styles
        // Using a dictionary to store label configurations
        let labelConfigs: [(UILabel?, CGFloat, UIFont.Weight, UIFont.TextStyle)] = [
            // Main equipment information - (label, size, weight, style)
            (equipmentNameLabel, 17, .bold, .headline),
            (discountedPriceHrLabel, 16, .semibold, .headline),
            (realPriceHrLabel, 14, .regular, .subheadline),
            (discountedPriceAcLabel, 16, .semibold, .headline),
            (realPriceAcLabel, 14, .regular, .subheadline),
            (coEquipDetailLabel, 14, .regular, .body),
            (locationLabel, 14, .regular, .body),
            (ratingLabel, 14, .regular, .body),
            (moreLabel, 12, .regular, .caption1),
            (ratingOutOf5Label, 16, .bold, .headline),
            (equipmentLocationDetailedLabel, 14, .regular, .body),
            (modelLabel, 14, .regular, .body),
            (capacityLabel, 14, .regular, .body),
            (mileageLabel, 14, .regular, .body),
            (hostedByLabel, 14, .regular, .body)
        ]
        
        // Apply settings to each label
        for (label, size, weight, style) in labelConfigs {
            if let lbl = label {
                // Enable dynamic type adjustment
                lbl.adjustsFontForContentSizeCategory = true
                
                // Create a base font of appropriate size and weight
                let baseFont = UIFont.systemFont(ofSize: size, weight: weight)
                
                // Use UIFontMetrics to get a properly scaled version
                lbl.font = UIFontMetrics(forTextStyle: style).scaledFont(for: baseFont)
            }
        }
    }
    
    @objc private func contentSizeCategoryDidChange() {
        // When text size changes, just reapply the styles and reload
        setDynamicTextStyles()
        tableView.reloadData() // Reload the table to adjust cell heights
    }
    
    private func configure(with equipment: Equipment) {
        // Set all the properties
        self.equipmentName = equipment.name
        self.discountedPriceHr = "₹ \(equipment.pricePerHour)/hr"
        self.realPriceHr = "₹ \(equipment.realPricePerHour)/hr"  // Added ₹ and /hr
        self.discountedPriceAc = "₹ \(equipment.pricePerAcre)/ac"
        self.realPriceAc = "₹ \(equipment.realPricePerAcre)/ac"  // Added ₹ and /ac
        self.coEquipDetail = "\(equipment.coEquipDetail) For CoEquip"
        self.location = equipment.location
        self.rating = "\(equipment.rating)"
        self.providerName = equipment.providerName ?? "Provider information unavailable"
        self.bigImage = equipment.equipmentImage
        self.smallImage1 = equipment.equipmentImage
        self.smallImage2 = equipment.equipmentImage
        self.smallImage3 = equipment.equipmentImage
        self.more = "\(equipment.equipmentMoreImages.images.count)"
        self.ratingOutOf5 = "\(equipment.rating)"
        self.equipmentLocationDetailed = equipment.location
        self.model = equipment.modelYear
        self.capacity = equipment.capacity
        self.mileage = equipment.mielage
        self.moreImages = equipment.equipmentMoreImages.images
        
        // Update the UI
        if isViewLoaded {
            updateEquipmentDescriptionData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // If we have filtered reviews, use those, otherwise return 0
        return filteredReviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! ReviewCardCollectionViewCell

        // Use filtered reviews
        let review = filteredReviews[indexPath.row]
            
        // Pass the review data to the update function in the cell
        cell.updateReviewCardData(reviewData: review)
      
        // Apply styling
        cell.layer.cornerRadius = 8
        cell.contentView.layer.cornerRadius = 8
        
        return cell
    }
    
    func updateEquipmentDescriptionData() {
        equipmentNameLabel.text = equipmentName
        discountedPriceHrLabel.text = discountedPriceHr
        
        // Safely handle realPriceHr
        if let price = realPriceHr {
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .strikethroughColor: UIColor.darkGray
            ]
            let attributedPrice = NSAttributedString(string: price, attributes: attributes)
            realPriceHrLabel.attributedText = attributedPrice
        } else {
            realPriceHrLabel.text = ""  // Set empty string or default value if nil
        }
        
        discountedPriceAcLabel.text = discountedPriceAc
        
        // Safely handle realPriceAc
        if let priceAc = realPriceAc {
            let attributes: [NSAttributedString.Key: Any] = [
                .strikethroughStyle: NSUnderlineStyle.single.rawValue,
                .strikethroughColor: UIColor.darkGray
            ]
            let attributedPriceAc = NSAttributedString(string: priceAc, attributes: attributes)
            realPriceAcLabel.attributedText = attributedPriceAc
        } else {
            realPriceAcLabel.text = ""  // Set empty string or default value if nil
        }
        
        coEquipDetailLabel.text = coEquipDetail
        locationLabel.text = location
        ratingLabel.text = rating
        
        // Set the provider name
        hostedByLabel.text = "Hosted by: \(providerName ?? "Provider information unavailable")"
        
        // Safely handle image names with support for URLs
        if let bigImageName = bigImage, let imageView = bigImageView {
            // Check if image name is a URL
            if bigImageName.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imageView.loadImage(from: bigImageName)
            } else {
                // Local asset
                imageView.image = UIImage(named: bigImageName) ?? UIImage(named: "placeholder_image")
            }
        }
        
        if let smallImage1Name = smallImage1, let imageView = smallImageView1 {
            // Check if image name is a URL
            if smallImage1Name.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imageView.loadImage(from: smallImage1Name)
            } else {
                // Local asset
                imageView.image = UIImage(named: smallImage1Name) ?? UIImage(named: "placeholder_image")
            }
        }
        
        if let smallImage2Name = smallImage2, let imageView = smallImageView2 {
            // Check if image name is a URL
            if smallImage2Name.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imageView.loadImage(from: smallImage2Name)
            } else {
                // Local asset
                imageView.image = UIImage(named: smallImage2Name) ?? UIImage(named: "placeholder_image")
            }
        }
        
        if let smallImage3Name = smallImage3, let imageView = smallImageView3 {
            // Check if image name is a URL
            if smallImage3Name.hasPrefix("http") {
                // It's a URL, use our ImageCache utility to load it
                imageView.loadImage(from: smallImage3Name)
            } else {
                // Local asset
                imageView.image = UIImage(named: smallImage3Name) ?? UIImage(named: "placeholder_image")
            }
        }
        
        moreLabel.text = "+ \(more)"
        ratingOutOf5Label.text = ratingOutOf5
        equipmentLocationDetailedLabel.text = location
        modelLabel.text = model
        capacityLabel.text = capacity
        mileageLabel.text = mileage
    }
    
    
    @IBAction func bookButtonTapped(_ sender: UIButton) {
        // Check the booking source to determine the flow
        if bookingSource == .prebooking {
            // If coming from Prebooking tab, go directly to ReviewBooking with prebooking flow
            navigateToReviewBooking()
        } else {
            // For other sources (like Home tab), show the booking options
            showBookingOptions()
        }
    }
    
    func showBookingOptions() {
        let alertController = UIAlertController(title: "Choose Your Booking Type", message: "Book individually or join with nearby farmers for reduced costs. ", preferredStyle: .alert)
        
        let individualAction = UIAlertAction(title: "Book as Individual", style: .default) { _ in
            
            self.navigateToReviewBooking()
            
        }
        
        let coEquipAction = UIAlertAction(title: "Book with Co-Equip", style: .default) { _ in
            self.navigateToCoEquipBooking()
        }
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        individualAction.setValue(UIColor.init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
        coEquipAction.setValue(UIColor.init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
        cancelAction.setValue(UIColor.init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1), forKey: "titleTextColor")
        alertController.addAction(individualAction)
        alertController.addAction(coEquipAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    

    
    func navigateToReviewBooking() {
        if let equipment = self.equipment {
            performSegue(withIdentifier: "ReviewBookingSegue", sender: self)
        } else {
            let alert = UIAlertController(
                title: "Error",
                message: "No equipment selected. Please select equipment first.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
    }
    
    
    func navigateToCoEquipBooking() {
        guard let equipment = self.equipment else {
            let alert = UIAlertController(
                title: "Error",
                message: "No equipment selected. Please select equipment first.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
        if let viewController = storyboard.instantiateViewController(withIdentifier: "InfoTableViewController") as? InfoTableViewController {
            // Pass the equipment data
            viewController.cardData = equipment
            // Set the data controller if needed
            if let dataController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.dataController {
                viewController.dataController = dataController
            }
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReviewBookingSegue" {
            if let destinationVC = segue.destination as? ReviewBookingTableViewController {
                
                guard let equipment = self.equipment else {
                    return
                }
                destinationVC.bookingSource = self.bookingSource
                destinationVC.equipment = equipment
                destinationVC.locationLabel.text = equipment.location
                destinationVC.pricePerHr = equipment.pricePerHour
            }
        } else if segue.identifier == "MoreImageView" {
            if let destinationVC = segue.destination as? ImageViewCollectionViewController {
                destinationVC.imageNames = moreImages
            }
        }
    }

    
    @IBAction func moreImageButtonTapped(_ sender: UIButton) {
        performSegue(withIdentifier: "MoreImageView", sender: self)
    }
    
    deinit {
        // Remove notification observer when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Review Section Management
    
    private func setupReviewsSection() {
        print("Setting up review section")
        
        // Create the no reviews view
        noReviewsView = NoReviewsView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 200))
        if noReviewsView == nil {
            print("ERROR: Failed to initialize NoReviewsView")
        }
        noReviewsView?.onWriteReviewTapped = { [weak self] in
            self?.presentReviewSheet()
        }
        
        // Create the reviews header view
        reviewsHeaderView = ReviewsHeaderView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 100))
        if reviewsHeaderView == nil {
            print("ERROR: Failed to initialize ReviewsHeaderView")
        }
        reviewsHeaderView?.onWriteReviewTapped = { [weak self] in
            self?.presentReviewSheet()
        }
        
        print("Review section setup complete. NoReviewsView: \(noReviewsView != nil), ReviewsHeaderView: \(reviewsHeaderView != nil)")
    }
    
    private func refreshReviews(for equipment: Equipment) {
        print("Filtering reviews for equipment: \(equipment.name) with ID: \(equipment.equipmentID.uuidString)")
        
        // Get all available reviews
        let allReviews = ReviewDataClass.reviews
        print("Total reviews available: \(allReviews.count)")
        
        // Print all reviews for debugging
        for (index, review) in allReviews.enumerated() {
            print("Review \(index + 1):")
            print("  - Heading: \(review.reviewHeading)")
            print("  - Equipment ID: \(review.equipmentID ?? "nil")")
            print("  - Equipment Name: \(review.equipmentName ?? "nil")")
        }
        
        // Filter reviews for this equipment (by name since IDs might not match)
        filteredReviews = allReviews.filter { review in
            // If we have equipmentID, use that for matching - with case-insensitive comparison
            if let reviewEquipmentID = review.equipmentID {
                let equipmentID = equipment.equipmentID.uuidString
                // Make the comparison case-insensitive to handle uppercase/lowercase UUIDs
                let matches = reviewEquipmentID.lowercased() == equipmentID.lowercased()
                print("Comparing IDs: \(reviewEquipmentID) == \(equipmentID) = \(matches)")
                return matches
            }
            
            // Otherwise use the equipment name (case insensitive)
            if let reviewEquipmentName = review.equipmentName {
                let matches = reviewEquipmentName.lowercased() == equipment.name.lowercased()
                print("Comparing names: \(reviewEquipmentName) == \(equipment.name) = \(matches)")
                return matches
            }
            
            print("Review has no equipment ID or name, skipping")
            return false
        }
        
        print("Filtered reviews for \(equipment.name): \(filteredReviews.count)")
        
        // Update UI based on reviews count
        updateReviewSectionUI()
    }
    
    private func checkUserBookingStatus(for equipment: Equipment) {
        // Get current user
        guard let dataController = dataController,
              let currentUser = dataController.getCurrentUser() else {
            userCanWriteReview = false
            updateReviewSectionUI()
            return
        }
        
        // Check if user has any completed bookings for this equipment
        // Fix: Since getBookings() is not available, we'll use a workaround
        // We'll assume no bookings for now and simulate the check
        
        // Workaround - simulate checking bookings
        let hasCompletedBooking = checkIfUserCompletedBooking(userID: currentUser.userID, equipmentID: equipment.equipmentID)
        
        userCanWriteReview = hasCompletedBooking
        updateReviewSectionUI()
    }
    
    // Helper method to check if user has completed booking for this equipment
    private func checkIfUserCompletedBooking(userID: UUID, equipmentID: UUID) -> Bool {
        // In a real implementation, this would check the database
        // For now, we'll simulate it by checking if both IDs are valid
        
        // Breaking up the complex expression to avoid compiler issues
        let isValidUserID = !userID.uuidString.isEmpty
        let isValidEquipmentID = !equipmentID.uuidString.isEmpty
        
        // For testing purposes, return true to allow writing reviews
        // In production, this should check actual booking history
        return isValidUserID && isValidEquipmentID
    }
    
    private func updateReviewSectionUI() {
        print("Updating review section UI. Filtered reviews count: \(filteredReviews.count)")
        
        DispatchQueue.main.async {
            // Find review section cell by looking through all sections
            if self.reviewsSection == nil {
                // Try to find the review section by its title
                let sectionCount = self.tableView.numberOfSections
                print("Table has \(sectionCount) sections, searching for Reviews section")
                
                // Look through all sections for the one with "Rating & Reviews" header
                var foundSection = -1
                for section in 0..<sectionCount {
                    if let headerView = self.tableView.headerView(forSection: section),
                       let headerTitle = headerView.textLabel?.text,
                       headerTitle.contains("Rating") || headerTitle.contains("Reviews") {
                        foundSection = section
                        print("Found Reviews section at index: \(section)")
                        break
                    }
                }
                
                // If found, get the cell
                if foundSection >= 0 {
                    let indexPath = IndexPath(row: 0, section: foundSection)
                    self.reviewsSection = self.tableView.cellForRow(at: indexPath)
                    print("Looking for review section cell at section \(foundSection), row 0. Found: \(self.reviewsSection != nil)")
                } else {
                    print("ERROR: Could not find the Reviews section in the table. Trying section 2 as fallback.")
                    // Try section 2 as fallback
                    if self.tableView.numberOfSections > 2 {
                        let indexPath = IndexPath(row: 0, section: 2)
                        self.reviewsSection = self.tableView.cellForRow(at: indexPath)
                        print("Fallback: Looking for review section cell at section 2, row 0. Found: \(self.reviewsSection != nil)")
                    }
                }
            }
            
            // If we still can't find the section, try a different approach
            if self.reviewsSection == nil {
                print("Still can't find review section. Creating it if needed.")
                // Force a table reload to ensure cells are created
                self.tableView.reloadData()
                
                // Wait for the next run loop to get the cell
                DispatchQueue.main.async {
                    // Try using a visible cell from the section where reviews should be
                    let visibleCells = self.tableView.visibleCells
                    if visibleCells.count > 3 { // Assuming reviews might be the 3rd or 4th cell
                        self.reviewsSection = visibleCells[min(3, visibleCells.count - 1)]
                        print("Using visible cell as review section. Found: \(self.reviewsSection != nil)")
                    }
                    
                    // Continue with the rest of the function using whatever cell we found
                    self.configureReviewContent()
                }
                return // Exit early, the nested async call will handle the rest
            }
            
            // Configure the content with the cell we found
            self.configureReviewContent()
        }
    }
    
    // Helper method to configure the review content
    private func configureReviewContent() {
        guard let reviewsCell = self.reviewsSection else {
            print("ERROR: Still could not find the reviews section cell")
            return
        }
        
        // Clear existing content views
        for subview in reviewsCell.contentView.subviews {
            if subview is NoReviewsView || subview is ReviewsHeaderView || subview is UICollectionView {
                subview.removeFromSuperview()
            }
        }
        
        // Configure based on reviews count
        if self.filteredReviews.isEmpty {
            print("No reviews to display. Showing NoReviewsView")
            // Configure no reviews view
            if let noReviewsView = self.noReviewsView {
                noReviewsView.configure(canUserWriteReview: self.userCanWriteReview)
                noReviewsView.frame = CGRect(x: 0, y: 0, width: reviewsCell.contentView.bounds.width, height: 200)
                reviewsCell.contentView.addSubview(noReviewsView)
                
                // Setup constraints
                noReviewsView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    noReviewsView.topAnchor.constraint(equalTo: reviewsCell.contentView.topAnchor),
                    noReviewsView.leadingAnchor.constraint(equalTo: reviewsCell.contentView.leadingAnchor),
                    noReviewsView.trailingAnchor.constraint(equalTo: reviewsCell.contentView.trailingAnchor),
                    noReviewsView.bottomAnchor.constraint(equalTo: reviewsCell.contentView.bottomAnchor),
                    noReviewsView.heightAnchor.constraint(equalToConstant: 200)
                ])
            } else {
                print("ERROR: NoReviewsView is nil")
            }
        } else {
            print("Displaying \(self.filteredReviews.count) reviews")
            // Calculate average rating
            let averageRating = self.filteredReviews.reduce(0.0) { $0 + $1.rating } / Double(self.filteredReviews.count)
            
            // Configure reviews header view
            if let reviewsHeaderView = self.reviewsHeaderView {
                reviewsHeaderView.configure(
                    with: averageRating,
                    canUserWriteReview: self.userCanWriteReview,
                    reviewsCount: self.filteredReviews.count
                )
                
                // Add "See All Reviews" action
                reviewsHeaderView.onSeeAllReviewsTapped = { [weak self] in
                    self?.showAllReviews()
                }
                
                reviewsHeaderView.frame = CGRect(x: 0, y: 0, width: reviewsCell.contentView.bounds.width, height: 100)
                reviewsCell.contentView.addSubview(reviewsHeaderView)
                
                // Setup constraints
                reviewsHeaderView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    reviewsHeaderView.topAnchor.constraint(equalTo: reviewsCell.contentView.topAnchor),
                    reviewsHeaderView.leadingAnchor.constraint(equalTo: reviewsCell.contentView.leadingAnchor),
                    reviewsHeaderView.trailingAnchor.constraint(equalTo: reviewsCell.contentView.trailingAnchor),
                    reviewsHeaderView.heightAnchor.constraint(equalToConstant: 100)
                ])
            } else {
                print("ERROR: ReviewsHeaderView is nil")
            }
            
            // Configure collection view for reviews
            if let collectionView = self.collectionView {
                // Increase the height from 180 to 220 to accommodate more content
                collectionView.frame = CGRect(x: 0, y: 100, width: reviewsCell.contentView.bounds.width, height: 220)
                reviewsCell.contentView.addSubview(collectionView)
                
                // Setup constraints
                collectionView.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    collectionView.topAnchor.constraint(equalTo: self.reviewsHeaderView!.bottomAnchor),
                    collectionView.leadingAnchor.constraint(equalTo: reviewsCell.contentView.leadingAnchor),
                    collectionView.trailingAnchor.constraint(equalTo: reviewsCell.contentView.trailingAnchor),
                    collectionView.bottomAnchor.constraint(equalTo: reviewsCell.contentView.bottomAnchor),
                    // Increase the height constraint from 180 to 220
                    collectionView.heightAnchor.constraint(equalToConstant: 220)
                ])
                
                collectionView.reloadData()
                print("CollectionView reloaded with \(self.filteredReviews.count) reviews")
            } else {
                print("ERROR: CollectionView is nil")
            }
        }
        
        // Refresh the table view layout
        self.refreshTableViewLayout()
    }
    
    // Show all reviews in a full-screen view
    private func showAllReviews() {
        guard let equipment = equipment, !filteredReviews.isEmpty else { return }
        
        // For now, just show an alert with the number of reviews
        // In a real implementation, you'd create a dedicated reviews list view controller
        let alertController = UIAlertController(
            title: "All Reviews",
            message: "This would show all \(filteredReviews.count) reviews for \(equipment.name) in a full-screen view.",
            preferredStyle: .alert
        )
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
    
    // Refresh table view layout to adjust cell heights
    private func refreshTableViewLayout() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Review Action
    
    @objc func presentReviewSheet() {
        guard let equipment = equipment else { return }
        
        let alertController = UIAlertController(title: "Write a Review", message: "Share your experience with \(equipment.name)", preferredStyle: .alert)
        
        // Add text fields for review title and description
        alertController.addTextField { textField in
            textField.placeholder = "Review Title"
        }
        
        alertController.addTextField { textField in
            textField.placeholder = "Review Description"
            textField.returnKeyType = .done
        }
        
        // Add rating controller
        let ratingController = UIViewController()
        let ratingView = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 60))
        
        let starStackView = UIStackView(frame: CGRect(x: 20, y: 10, width: 230, height: 40))
        starStackView.axis = .horizontal
        starStackView.distribution = .fillEqually
        starStackView.spacing = 10
        
        var starButtons: [UIButton] = []
        var currentRating = 5 // Default rating
        
        // Create star buttons
        for i in 1...5 {
            let starButton = UIButton(type: .system)
            starButton.setImage(UIImage(systemName: "star.fill"), for: .normal)
            starButton.tintColor = i <= currentRating ? 
                UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1) : 
                UIColor.systemGray3
            starButton.tag = i
            starButton.addTarget(ratingController, action: #selector(UIViewController.starButtonTapped(_:)), for: .touchUpInside)
            starStackView.addArrangedSubview(starButton)
            starButtons.append(starButton)
        }
        
        ratingView.addSubview(starStackView)
        ratingController.view = ratingView
        alertController.setValue(ratingController, forKey: "contentViewController")
        
        // Add action to the view controller for the star buttons
        let originalStarTapped = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.starButtonTapped(_:)))
        let newStarTapped = class_getInstanceMethod(UIViewController.self, #selector(UIViewController.ratingStarButtonTapped(_:)))
        if let originalMethod = originalStarTapped, let newMethod = newStarTapped {
            method_exchangeImplementations(originalMethod, newMethod)
        }
        
        // Add submit action
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] _ in
            guard let self = self,
                  let titleField = alertController.textFields?[0],
                  let descriptionField = alertController.textFields?[1],
                  let title = titleField.text, !title.isEmpty,
                  let description = descriptionField.text, !description.isEmpty,
                  let equipment = self.equipment else {
                return
            }
            
            // Get selected rating from ratingController
            let rating = Double(ratingController.selectedRating)
            
            // Create new review
            let newReview = ReviewData(
                reviewHeading: title,
                reviewDescription: description,
                rating: rating,
                equipmentID: equipment.equipmentID.uuidString,
                equipmentName: equipment.name
            )
            
            // Add to reviews
            ReviewDataClass.reviews.append(newReview)
            
            // Refresh UI
            self.refreshReviews(for: equipment)
            
            // Swap back methods to avoid memory issues
            if let originalMethod = originalStarTapped, let newMethod = newStarTapped {
                method_exchangeImplementations(newMethod, originalMethod)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            // Swap back methods to avoid memory issues
            if let originalMethod = originalStarTapped, let newMethod = newStarTapped {
                method_exchangeImplementations(newMethod, originalMethod)
            }
        }
        
        alertController.addAction(submitAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    // MARK: - Table View Delegate Methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Check if this is the reviews section
        if indexPath.section == 2 { // Assuming reviews are in section 2
            // If we have reviews, make the cell taller to accommodate them
            if !filteredReviews.isEmpty {
                // Height for header (100) + height for collection view (220) + padding (40)
                return 360
            } else {
                // Height for the "No Reviews" view
                return 200
            }
        }
        
        // For other sections, use automatic sizing
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 { // Reviews section
            return 360
        }
        return UITableView.automaticDimension
    }
}

// Extension for the star rating
extension UIViewController {
    @objc func starButtonTapped(_ sender: UIButton) {
        // This will be replaced
    }
    
    @objc func ratingStarButtonTapped(_ sender: UIButton) {
        let selectedRating = sender.tag
        
        // Update star appearances
        if let ratingView = self.view,
           let starStackView = ratingView.subviews.first as? UIStackView {
            for subview in starStackView.arrangedSubviews {
                if let starButton = subview as? UIButton {
                    let isFilled = starButton.tag <= selectedRating
                    starButton.tintColor = isFilled ? 
                        UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1) : 
                        UIColor.systemGray3
                }
            }
        }
        
        // Store the selected rating for later use
        objc_setAssociatedObject(self, "selectedRating", selectedRating, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    // Utility method to get the selected rating
    var selectedRating: Int {
        return objc_getAssociatedObject(self, "selectedRating") as? Int ?? 5
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Extension

extension EquipmentDescriptionTableViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // Calculate item width (80% of collection view width)
        let width: CGFloat = collectionView.bounds.width * 0.85
        
        // Increase height to fit review content properly
        let height: CGFloat = 160 // Increased from previous value
        
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        // Add some padding around the cells
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
}
