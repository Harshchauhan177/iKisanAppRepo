//
//  preBookingEquipmentSection4CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 23/01/25.
//

import UIKit
import Foundation

protocol FAQCellDelegate: AnyObject {
    func didTapFAQ(at index: Int)
}

class preBookingFAQSectionCollectionViewCell: UICollectionViewCell {

    // Keep the original IBOutlet to avoid KVC errors with existing storyboard connections
    @IBOutlet weak var needHelpLabel: UILabel?
    
    // UI Elements
    private let containerView = UIView()
    private let questionLabel = UILabel()
    private let chevronImageView = UIImageView()
    private let separatorView = UIView()
    
    // Properties
    private var faqItem: FAQ?
    private var index: Int = 0
    weak var delegate: FAQCellDelegate?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    // MARK: - Configuration
    
    func configure(with faq: FAQ, index: Int) {
        self.faqItem = faq
        self.index = index
        
        questionLabel.text = faq.question
    }
    
    func updatePreBookingSection4Data(with indexPath: IndexPath) {
        // This method is kept for backward compatibility
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // Setup container view with grouped style background
        containerView.backgroundColor = .white
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Add rounded corners for grouped style
        contentView.backgroundColor = .systemGroupedBackground
        containerView.layer.cornerRadius = 0 // Will be set in layoutSubviews
        containerView.clipsToBounds = true
        
        // Setup question label with dynamic type support
        questionLabel.adjustsFontForContentSizeCategory = true
        let baseFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        questionLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        questionLabel.textColor = .black
        questionLabel.numberOfLines = 1 // Single line like iOS settings
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(questionLabel)
        
        // Register for content size category changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
        
        // Setup chevron image - use standard iOS chevron
        chevronImageView.contentMode = .scaleAspectFit
        chevronImageView.tintColor = UIColor.systemGray2
        chevronImageView.translatesAutoresizingMaskIntoConstraints = false
        chevronImageView.image = UIImage(systemName: "chevron.right")
        containerView.addSubview(chevronImageView)
        
        // Setup separator like iOS settings
        separatorView.backgroundColor = UIColor.systemGray5
        separatorView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(separatorView)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        // Setup constraints to match iOS settings style
        NSLayoutConstraint.activate([
            // Container view constraints with margins for grouped style
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            // Question label constraints - centered vertically
            questionLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            questionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            questionLabel.trailingAnchor.constraint(equalTo: chevronImageView.leadingAnchor, constant: -12),
            
            // Chevron image constraints
            chevronImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            chevronImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            chevronImageView.widthAnchor.constraint(equalToConstant: 13), // Smaller chevron like in iOS settings
            chevronImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Separator view
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            separatorView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func handleTap() {
        delegate?.didTapFAQ(at: index)
    }
    
    @objc private func contentSizeCategoryDidChange() {
        // Refresh font when text size settings change
        let baseFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        questionLabel.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: baseFont)
        setNeedsLayout()
    }
    
    deinit {
        // Remove notification observer when cell is deallocated
        NotificationCenter.default.removeObserver(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Handle corner radius for grouped style
        // Get the section and row information from the collection view
        if let collectionView = self.superview as? UICollectionView,
           let indexPath = collectionView.indexPath(for: self) {
            
            // Get the number of items in this section
            let numberOfItems = collectionView.numberOfItems(inSection: indexPath.section)
            
            // Apply corner radius based on position
            if numberOfItems == 1 {
                // Single item in section - round all corners
                containerView.layer.cornerRadius = 10
                containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                separatorView.isHidden = true
            } else if indexPath.row == 0 {
                // First item in section - round top corners
                containerView.layer.cornerRadius = 10
                containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
                separatorView.isHidden = false
            } else if indexPath.row == numberOfItems - 1 {
                // Last item in section - round bottom corners
                containerView.layer.cornerRadius = 10
                containerView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
                separatorView.isHidden = true
            } else {
                // Middle item - no rounded corners
                containerView.layer.cornerRadius = 0
                separatorView.isHidden = false
            }
        }
    }
}
