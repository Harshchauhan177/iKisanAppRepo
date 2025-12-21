//
//  PhotosSection(UiKit)cell.swift
//  iKisanApp
//
//  Created by ANSHU NAGAR on 21/12/25.
//

import UIKit

class PhotosSectionUiKitCell: UIView {
    
    // MARK: - IBOutlets
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet weak var topLeftImageView: UIImageView!
    @IBOutlet weak var topRightImageView: UIImageView!
    @IBOutlet weak var bottomLeftImageView: UIImageView!
    //@IBOutlet weak var moreButton: UIButton!
    @IBOutlet weak var moreLabel: UILabel!
    
    @IBOutlet weak var viewAllContentView: UIView!
    // MARK: - Properties
    var onImageTapped: ((Int) -> Void)?
    var onMoreTapped: (() -> Void)?
    private var imageViews: [UIImageView] = []
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("PhotosSection(UiKit)cell", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupUI()
        setupGestures()
    }
    
    // MARK: - Setup
    private func setupUI() {
        // Apply corner radius to all image views following HIG
        
        viewAllContentView?.layer.cornerRadius = 12
        
        mainImageView?.layer.cornerRadius = 12
        mainImageView?.clipsToBounds = true
        mainImageView?.contentMode = .scaleAspectFill
        
        topLeftImageView?.layer.cornerRadius = 10
        topLeftImageView?.clipsToBounds = true
        topLeftImageView?.contentMode = .scaleAspectFill
        
        topRightImageView?.layer.cornerRadius = 10
        topRightImageView?.clipsToBounds = true
        topRightImageView?.contentMode = .scaleAspectFill
        
        bottomLeftImageView?.layer.cornerRadius = 10
        bottomLeftImageView?.clipsToBounds = true
        bottomLeftImageView?.contentMode = .scaleAspectFill
        
        // Store image views for easy access
        if let main = mainImageView, let topLeft = topLeftImageView,
           let topRight = topRightImageView, let bottom = bottomLeftImageView {
            imageViews = [main, topLeft, topRight, bottom]
        }
        
        // Configure View All label for accessibility and interaction
        moreLabel?.isUserInteractionEnabled = true
        moreLabel?.accessibilityLabel = "View all photos"
        moreLabel?.accessibilityHint = "Double tap to view all equipment photos"
        moreLabel?.accessibilityTraits = .button
    }
    
    private func setupGestures() {
        // Add tap gestures to images
        for (index, imageView) in imageViews.enumerated() {
            imageView.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
            tapGesture.numberOfTapsRequired = 1
            imageView.tag = index
            imageView.addGestureRecognizer(tapGesture)
        }
        
        // Add tap gesture to View All label
        if let label = moreLabel {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewAllLabelTapped))
            tapGesture.numberOfTapsRequired = 1
            label.addGestureRecognizer(tapGesture)
        }
    }
    
    // MARK: - Configuration
    func configure(with images: [String], remainingCount: Int) {
        guard images.count > 0 else {
            // No images available, show placeholder
            let placeholder = UIImage(systemName: "photo")
            mainImageView?.image = placeholder
            topLeftImageView?.image = placeholder
            topRightImageView?.image = placeholder
            bottomLeftImageView?.image = placeholder
            moreLabel?.text = "No Photos"
            return
        }
        
        let totalImages = images.count
        
        // Load main image (always first image)
        loadImage(images[0], into: mainImageView)
        
        // Load top-left image
        if totalImages >= 2 {
            loadImage(images[1], into: topLeftImageView)
        } else {
            loadImage(images[0], into: topLeftImageView)
        }
        
        // Load top-right image
        if totalImages >= 3 {
            loadImage(images[2], into: topRightImageView)
        } else if totalImages >= 2 {
            loadImage(images[1], into: topRightImageView)
        } else {
            loadImage(images[0], into: topRightImageView)
        }
        
        // Load bottom-left image
        if totalImages >= 4 {
            loadImage(images[3], into: bottomLeftImageView)
        } else if totalImages >= 3 {
            loadImage(images[2], into: bottomLeftImageView)
        } else if totalImages >= 2 {
            loadImage(images[1], into: bottomLeftImageView)
        } else {
            loadImage(images[0], into: bottomLeftImageView)
        }
        
        // Update more label to show "View All (count)"
        moreLabel?.text = "+ \(totalImages) more"
    }
    
    private func loadImage(_ imageName: String, into imageView: UIImageView?) {
        guard let imageView = imageView else { return }
        
        // Clear any existing image first
        imageView.image = nil
        
        if imageName.hasPrefix("http") {
            // Load from URL using the app's existing image loading mechanism
            imageView.loadImage(from: imageName)
        } else {
            // Load from assets
            imageView.image = UIImage(named: imageName) ?? UIImage(systemName: "photo")
        }
    }
    
    // MARK: - Actions
    @objc private func imageTapped(_ gesture: UITapGestureRecognizer) {
        let index = gesture.view?.tag ?? 0
        
        // Provide haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        onImageTapped?(index)
    }
    
    @objc private func viewAllLabelTapped() {
        // Provide haptic feedback following HIG
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        // Trigger the callback to show image gallery
        onMoreTapped?()
    }
}
