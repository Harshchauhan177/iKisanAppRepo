//
//  EquipmentDescriptionTableViewController.swift
//  iKisanApp
//
//  Created by ANSHU NAGAR on 18/01/25.
//

import UIKit

class EquipmentDescriptionTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: Section1 Equipment Deatils
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        if let equipment = equipment {
            configure(with: equipment)
        }
    }
    
    private func setupUI() {
        bigView.layer.cornerRadius = 10
        bigView.applyCardShadow()
        ratingView.layer.cornerRadius = 17
        //ratingView.applyCardShadow()
        bigImageView.layer.cornerRadius = 10
        smallImageView1.layer.cornerRadius = 7
        smallImageView2.layer.cornerRadius = 7
        smallImageView3.layer.cornerRadius = 7
        moreView.layer.cornerRadius = 7
       // moreView.applyCardShadow()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        //  collection view layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumLineSpacing = 20
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 16)
            collectionView.isPagingEnabled = true
        }
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
        return ReviewDataClass.reviews.count//EquipmentData.reviews.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! ReviewCardCollectionViewCell

        let review = ReviewDataClass.reviews[indexPath.row]
            
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
        
        // Safely handle image names
        if let bigImageName = bigImage {
            bigImageView.image = UIImage(named: bigImageName)
        }
        if let smallImage1Name = smallImage1 {
            smallImageView1.image = UIImage(named: smallImage1Name)
        }
        if let smallImage2Name = smallImage2 {
            smallImageView2.image = UIImage(named: smallImage2Name)
        }
        if let smallImage3Name = smallImage3 {
            smallImageView3.image = UIImage(named: smallImage3Name)
        }
        
        moreLabel.text = "+ \(more)"
        ratingOutOf5Label.text = ratingOutOf5
        equipmentLocationDetailedLabel.text = location
        modelLabel.text = model
        capacityLabel.text = capacity
        mileageLabel.text = mileage
    }
    
    
    @IBAction func bookButtonTapped(_ sender: UIButton) {
        showBookingOptions()
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
        
        let storyboard = UIStoryboard(name: "Tab3Coequip", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "InfoTableViewController") as!
        InfoTableViewController
        //viewController.sectionNumber = sender.tag
       navigationController?.pushViewController(viewController, animated: true)
//        if let coEquipBookingVC = storyboard?.instantiateViewController(withIdentifier: "InfoTableViewController"){
//            navigationController?.pushViewController(coEquipBookingVC, animated: true)
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReviewBookingSegue" {
            if let destinationVC = segue.destination as? ReviewBookingTableViewController {
                
                guard let equipment = self.equipment else {
                    return
                }
                
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
    
}
