//
//  EquipmentDescriptionTableViewController.swift
//  iKisanApp
//
//  Created by ANSHU NAGAR on 18/01/25.
//

import UIKit

class EquipmentDescriptionTableViewController: UITableViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //MARK: Section1 Equipment Deatils
    
    var Equipment : Equipment?
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
    var more: String?
    var ratingOutOf5: String?
    var equipmentLocationDetailed: String?
    var model: String?
    var capacity: String?
    var mileage: String?
    
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        equipmentNameLabel.text = "Equipment Name"
        //        navigationItem.title = name
        equipmentNameLabel.text = equipmentName
        collectionView.delegate = self
        collectionView.dataSource = self
        
        // Configure collection view layout
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            
            layout.minimumLineSpacing = 20
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
            collectionView.isPagingEnabled = true
        }
        updateEquipmentDescriptionData()
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCell", for: indexPath) as! ReviewCardCollectionViewCell
        // Configure the card cell (e.g., set text, images, etc.)
        //cell.updateReviewCardData(reviewData: ReviewData[indexPath.row])
        cell.feedbackHeadingLabel.text = "Feedback"
        cell.feedbackTextLabel.text = "Rented the Square Baler for my wheat field—excellent performance, fuel-efficient, and easy to use. The rental process was hassle-free."
        
        cell.layer.cornerRadius = 7
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        return CGSize(width: width, height: height)
    }
    
    //    func updateEquipmentDescriptionData(indexPath: IndexPath) {
    //        equipmentNameLabel.text = EquipmentData.equipment[indexPath.row].name/*equipmentDescriptionData.name*/
    //        discountedPriceHrLabel.text = "\(EquipmentData.equipment[indexPath.row].pricePerHour)"
    //        realPriceHrLabel.text = "\(EquipmentData.equipment[indexPath.row].realPricePerHour)"
    //        discountedPriceAcLabel.text = "\(EquipmentData.equipment[indexPath.row].pricePerAcre)"
    //        realPriceAcLabel.text = "\(EquipmentData.equipment[indexPath.row].realPricePerAcre)"
    //        coEquipDetailLabel.text = "\(EquipmentData.equipment[indexPath.row].coEquipDetail)"
    //        locationLabel.text = EquipmentData.equipment[indexPath.row].location
    //        ratingLabel.text  = "\(EquipmentData.equipment[indexPath.row].rating)"
    //
    //        //Data for Photos Section
    //        bigImageView.image = UIImage(named: EquipmentData.equipment[indexPath.row].equipmentMoreImages![0])
    //        smallImageView1.image = UIImage(named: EquipmentData.equipment[indexPath.row].equipmentMoreImages![1])
    //        smallImageView2.image = UIImage(named: EquipmentData.equipment[indexPath.row].equipmentMoreImages![2])
    //        smallImageView3.image = UIImage(named: EquipmentData.equipment[indexPath.row].equipmentMoreImages![3])
    //        moreLabel.text = "\(EquipmentData.equipment[indexPath.row].equipmentMoreImages!.count)"
    //
    //        //Rating
    //        ratingOutOf5Label.text = "\(EquipmentData.equipment[indexPath.row].rating)"
    //
    //        //Equipments Location Section
    //
    //        equipmentLocationDetailedLabel.text = EquipmentData.equipment[indexPath.row].location
    //    }
    
    func updateEquipmentDescriptionData() {
        equipmentNameLabel.text = equipmentName
        discountedPriceHrLabel.text = discountedPriceAc
        realPriceHrLabel.text = realPriceHr
        discountedPriceAcLabel.text = discountedPriceAc
        realPriceAcLabel.text = realPriceAc
        coEquipDetailLabel.text = coEquipDetail
        locationLabel.text = location
        ratingLabel.text  = rating
        
        // Data for Photos Section
        bigImageView.image = UIImage(named: bigImage!)
        smallImageView1.image = UIImage(named: smallImage1!)
        smallImageView2.image = UIImage(named: smallImage2!)
        smallImageView3.image = UIImage(named: smallImage3!)
        moreLabel.text = more //"\(Equipment.equipmentMoreImages!.count)"
        
        //Rating
        ratingOutOf5Label.text = ratingOutOf5
        
        //Equipments Location Section
        //
        equipmentLocationDetailedLabel.text = location
        
        moreLabel.text = more
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
        
        alertController.addAction(individualAction)
        alertController.addAction(coEquipAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func navigateToReviewBooking() {
        if let individualBookingVC = storyboard?.instantiateViewController(withIdentifier: "ReviewBookingTableViewController"){
            navigationController?.pushViewController(individualBookingVC, animated: true)
        }
    }
    
    func navigateToCoEquipBooking() {
        if let coEquipBookingVC = storyboard?.instantiateViewController(withIdentifier: "IndividualBookingViewController"){
            navigationController?.pushViewController(coEquipBookingVC, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ReviewBookingSegue" {
            if let destinationVC = segue.destination as? ReviewBookingTableViewController {
                destinationVC.locationA = location
                destinationVC.pricePerHr = Double(discountedPriceHr!)!
            }
        } else if segue.identifier == "CoEquipBookingSegue" {
//            let destinationVC = segue.destination as? CoEquipBookingViewController
//            destinationVC.location = location
//            destinationVC.pricePerHr = Double(discountedPriceHr!)
        }
        
    }
    
}
        
