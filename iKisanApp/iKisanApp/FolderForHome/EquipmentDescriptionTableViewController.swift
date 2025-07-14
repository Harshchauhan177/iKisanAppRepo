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
        setupRatingLabel()
        setupReviewsSection()
        if let equipment = equipment {
            configure(with: equipment)
        }
        
        // Initialize dataController if needed
        dataController = IKisanDataController()
    }
    
    private func setupRatingLabel() {
        // Configure the rating label to ensure it displays properly
        if let ratingLabel = ratingOutOf5Label {
            ratingLabel.font = UIFont.systemFont(ofSize: 36, weight: .bold)
            ratingLabel.adjustsFontSizeToFitWidth = true
            ratingLabel.minimumScaleFactor = 0.5
            ratingLabel.textAlignment = .left
            
            // Set minimum width to ensure all digits are visible
            if let superview = ratingLabel.superview {
                let widthConstraint = ratingLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: 80)
                widthConstraint.priority = .defaultHigh
                widthConstraint.isActive = true
            }
        }
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
            collectionView.backgroundColor = UIColor(red: 235/255.0, green: 235/255.0, blue: 235/255.0, alpha: 1.0)
            //collectionView.backgroundColor = .systemBackground
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
            (coEquipDetailLabel, 14, .bold, .body),
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
        
        // Initialize moreImages with at least the main equipment image if empty
        if self.moreImages.isEmpty {
            self.moreImages = [equipment.equipmentImage]
        }
        
        // Check if the user has booked this equipment to determine if they can write a review
        checkUserBookingStatus(for: equipment)
        
        // Fetch additional images from Supabase to update the "More" button count
        fetchMoreImagesFromSupabase { [weak self] in
            // No need to do anything here as the fetching updates the UI automatically
        }
        
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
            // ratingLabel.text = ratingOutOf5
        
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
                // Only pass the data model objects, not directly modifying UI elements
                destinationVC.bookingSource = self.bookingSource
                destinationVC.equipment = equipment
                destinationVC.equipmentLocation = equipment.location
                destinationVC.pricePerHr = equipment.pricePerHour
                
                // Let the destination view controller update its own UI elements
                // in viewDidLoad or viewWillAppear
            }
        } else if segue.identifier == "MoreImageView" {
            print("Preparing MoreImageView segue - passing \(moreImages.count) images")
            
            // Handle both direct presentation and navigation controller presentation
            var destinationVC: ImageViewCollectionViewController?
            
            if let imageVC = segue.destination as? ImageViewCollectionViewController {
                destinationVC = imageVC
            } else if let navController = segue.destination as? UINavigationController,
                      let imageVC = navController.topViewController as? ImageViewCollectionViewController {
                destinationVC = imageVC
            }
            
            if let imageVC = destinationVC {
                imageVC.imageNames = moreImages
                print("Images passed to destination: \(moreImages)")
            }
        }
    }

    
    @IBAction func moreImageButtonTapped(_ sender: UIButton) {
        print("More button tapped - performing segue with \(moreImages.count) images")
        
        // If images haven't been fetched yet, fetch them first
        if moreImages.isEmpty || moreImages.count == 1 {
            print("Images not loaded yet, fetching now...")
            
            // Show loading indicator
            sender.isEnabled = false
            sender.setTitle("Loading...", for: .normal)
            
            // Fetch more images from Supabase
            fetchMoreImagesFromSupabase { [weak self] in
                DispatchQueue.main.async {
                    // Reset button state
                    sender.isEnabled = true
                    sender.setTitle("More", for: .normal)
                    
                    print("Fetching complete - performing segue with \(self?.moreImages.count ?? 0) images")
                    
                    // Perform segue with updated images
                    self?.performSegue(withIdentifier: "MoreImageView", sender: self)
                }
            }
        } else {
            // Images already loaded, go directly to image view
            performSegue(withIdentifier: "MoreImageView", sender: self)
        }
    }
    
    // MARK: - Fetch More Images from Supabase
    
    private func fetchMoreImagesFromSupabase(completion: @escaping () -> Void) {
        guard let equipment = equipment else {
            print("Error: No equipment available for fetching more images")
            completion()
            return
        }
        
        print("Fetching more images for equipment ID: \(equipment.equipmentID.uuidString)")
        
        Task {
            do {
                let imageRecords: [EquipmentImageRecord] = try await SupabaseManager.shared.client
                    .from("equipmentMoreImages")
                    .select("*")
                    .eq("equipmentID", value: equipment.equipmentID.uuidString)
                    .execute()
                    .value
                
                // Extract image URLs from the records
                let imageUrls = imageRecords.map { $0.image }
                
                // Include the main equipment image as the first image
                var allImages = [equipment.equipmentImage]
                allImages.append(contentsOf: imageUrls)
                
                // Update moreImages array on main thread
                await MainActor.run {
                    self.moreImages = allImages
                    // Update the more button text to reflect actual count
                    self.more = "\(imageUrls.count)"
                    if let moreLabel = self.moreLabel {
                        moreLabel.text = "+ \(self.more)"
                    }
                    print("Successfully fetched \(imageUrls.count) additional images for equipment: \(equipment.name)")
                    print("Total images available: \(allImages.count)")
                    completion()
                }
                
            } catch {
                print("Error fetching more images from Supabase: \(error)")
                
                // Fallback to showing just the main equipment image
                await MainActor.run {
                    self.moreImages = [equipment.equipmentImage]
                    completion()
                }
            }
        }
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
        // Check if we have a data controller - use it to quickly check local bookings
        if let dataController = dataController {
            // Get all bookings for this user and equipment using the new method
            let userBookings = dataController.getUserBookings(userID: userID, equipmentID: equipmentID)
            
            // If we have any matching bookings, user can write a review
            if !userBookings.isEmpty {
                print("User has \(userBookings.count) bookings for this equipment")
                return true
            }
        }
        
        // If no matches in local data, fetch from the backend
        // We'll do this asynchronously and update the UI when complete
        Task {
            print("Checking user booking history for equipment ID: \(equipmentID)")
            
            // Fetch bookings from backend
            let fetchedBookings = await RequestManager.shared.fetchBookings()
            
            // Check if any bookings match this user and equipment
            let matchingBookings = fetchedBookings.filter { booking in
                return booking.userID == userID && booking.equipmentID == equipmentID
            }
            
            // Update UI on main thread if we found matching bookings
            if !matchingBookings.isEmpty {
                print("Found \(matchingBookings.count) matching bookings from backend")
                await MainActor.run {
                    self.userCanWriteReview = true
                    self.updateReviewSectionUI()
                }
                return
            }
            
            // If we still haven't found any bookings, ensure user cannot write review
            await MainActor.run {
                self.userCanWriteReview = false
                self.updateReviewSectionUI()
            }
        }
        
        // Default to false until async check completes
        return false
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
            
            // Update the rating display label as well
            if let ratingOutOf5Label = self.ratingOutOf5Label {
                ratingOutOf5Label.text = String(format: "%.1f", averageRating)
            }
            if let ratingLabel = self.ratingLabel {
                ratingLabel.text = String(format: "%.1f", averageRating)
            }
            
            
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
                
                // Make sure reviewsHeaderView is not nil before using it
                if let reviewsHeaderView = self.reviewsHeaderView {
                    NSLayoutConstraint.activate([
                        collectionView.topAnchor.constraint(equalTo: reviewsHeaderView.bottomAnchor),
                        collectionView.leadingAnchor.constraint(equalTo: reviewsCell.contentView.leadingAnchor),
                        collectionView.trailingAnchor.constraint(equalTo: reviewsCell.contentView.trailingAnchor),
                        collectionView.bottomAnchor.constraint(equalTo: reviewsCell.contentView.bottomAnchor),
                        // Increase the height constraint from 180 to 220
                        collectionView.heightAnchor.constraint(equalToConstant: 220)
                    ])
                } else {
                    // Fallback if reviewsHeaderView is nil
                    NSLayoutConstraint.activate([
                        collectionView.topAnchor.constraint(equalTo: reviewsCell.contentView.topAnchor, constant: 100),
                        collectionView.leadingAnchor.constraint(equalTo: reviewsCell.contentView.leadingAnchor),
                        collectionView.trailingAnchor.constraint(equalTo: reviewsCell.contentView.trailingAnchor),
                        collectionView.bottomAnchor.constraint(equalTo: reviewsCell.contentView.bottomAnchor),
                        collectionView.heightAnchor.constraint(equalToConstant: 220)
                    ])
                    print("WARNING: reviewsHeaderView is nil when setting up collection view constraints")
                }
                
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
        
        // Create and configure the all reviews view controller
        let allReviewsVC = AllReviewsViewController()
        allReviewsVC.equipment = equipment
        allReviewsVC.reviews = filteredReviews
        
        // Present the view controller
        navigationController?.pushViewController(allReviewsVC, animated: true)
    }
    
    // Refresh table view layout to adjust cell heights
    private func refreshTableViewLayout() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    // MARK: - Review Action
    
    @objc func presentReviewSheet() {
        guard let equipment = equipment else { return }
        
        // Check if user can write a review before showing the review sheet
        if !userCanWriteReview {
            // Show alert explaining why they can't write a review
            let alert = UIAlertController(
                title: "Cannot Write Review",
                message: "You need to book and use this equipment before writing a review.",
                preferredStyle: .alert
            )
            let okAction = UIAlertAction(title: "OK", style: .default)
            alert.addAction(okAction)
            present(alert, animated: true)
            return
        }
        
        // Create the write review view controller
        let writeReviewVC = WriteReviewViewController()
        writeReviewVC.equipment = equipment
        
        // Get data controller reference for saving to backend
        if let dataController = (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.dataController {
            writeReviewVC.dataController = dataController
        }
        
        // Set up callback for when review is submitted
        writeReviewVC.onReviewSubmitted = { [weak self] newReview in
            guard let self = self else { return }
            // Refresh UI after review is submitted
            self.refreshReviews(for: equipment)
        }
        
        // Create a navigation controller to wrap the review view controller
        let navController = UINavigationController(rootViewController: writeReviewVC)
        navController.modalPresentationStyle = .pageSheet
        
        if #available(iOS 15.0, *) {
            // For iOS 15+ use sheet presentation controller for better appearance
            if let sheet = navController.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = true
            }
        }
        
        // Present the navigation controller
        present(navController, animated: true)
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

// Extension for UI components
extension UIViewController {
    // Add any shared functionality here if needed
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
