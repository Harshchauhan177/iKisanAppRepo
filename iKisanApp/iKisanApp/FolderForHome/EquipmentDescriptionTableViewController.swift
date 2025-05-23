//
//  EquipmentDescriptionTableViewController.swift
//  iKisanApp
//
//  Created by ANSHU NAGAR on 18/01/25.
//

import UIKit

class EquipmentDescriptionTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    // Add this property near the top of the class with other properties
    var selectedDate: Date?
    
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
    
    private var reviews: [ReviewData] = []
    private var dataController: DataController?
    private var filteredReviews: [ReviewData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
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
            print("Filtering reviews for equipment: \(equipment.name)")
            
            // Get all available reviews
            let allReviews = ReviewDataClass.reviews
            print("Total reviews available: \(allReviews.count)")
            
            // Filter reviews for this equipment (by name since IDs might not match)
            filteredReviews = allReviews.filter { review in
                // If we have equipmentID, use that for matching
                if let reviewEquipmentID = review.equipmentID {
                    let equipmentID = equipment.equipmentID.uuidString
                    return reviewEquipmentID == equipmentID
                }
                
                // Otherwise use the equipment name (case insensitive)
                if let reviewEquipmentName = review.equipmentName {
                    return reviewEquipmentName.lowercased() == equipment.name.lowercased()
                }
                
                // For now, if name is "Square Balers", show all reviews as a fallback
                if equipment.name.contains("Square Balers") {
                    return true
                }
                
                return false
            }
            
            print("Filtered reviews for \(equipment.name): \(filteredReviews.count)")
            
            // Reload the collection view to show reviews
            DispatchQueue.main.async {
                self.collectionView.reloadData()
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
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 16)
            collectionView.isPagingEnabled = true
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
    
    func configure(with equipment: Equipment) {
        
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
        // If we have filtered reviews, use those, otherwise fall back to all reviews
        if !filteredReviews.isEmpty {
            return filteredReviews.count
        }
        return ReviewDataClass.reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! ReviewCardCollectionViewCell

        // Use filtered reviews if available, otherwise fall back to all reviews
        let review = !filteredReviews.isEmpty ? filteredReviews[indexPath.row] : ReviewDataClass.reviews[indexPath.row]
            
        // Pass the review data to the update function in the cell
        cell.updateReviewCardData(reviewData: review)
      
        cell.layer.cornerRadius = 7
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
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
            
            // Get the date from CreateRequestViewController if available
            // In navigateToCoEquipBooking()
            if let createRequestVC = self.navigationController?.viewControllers.first(where: { $0 is CreateRequestViewController }) as? CreateRequestViewController {
                viewController.date = createRequestVC.selectedCalendarDate  // Change from selectedDate to selectedCalendarDate
            }
            
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
                destinationVC.locationA = equipment.location
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
}
