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
    private let answerLabel = UILabel()
    private let arrowImageView = UIImageView()
    
    // Properties
    private var faqItem: FAQ?
    private var isExpanded = false
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
    
    func configure(with faq: FAQ, index: Int, isExpanded: Bool) {
        self.faqItem = faq
        self.index = index
        self.isExpanded = isExpanded
        
        questionLabel.text = faq.question
        answerLabel.text = faq.answer
        
        // Show/hide answer based on expanded state
        updateExpandedState()
    }
    
    func updatePreBookingSection4Data(with indexPath: IndexPath) {
        // This method is kept for backward compatibility
    }
    
    // MARK: - Setup
    
    private func setupViews() {
        // Setup container view
        containerView.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        containerView.layer.cornerRadius = 10
        containerView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(containerView)
        
        // Setup question label
        questionLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        questionLabel.textColor = .black
        questionLabel.numberOfLines = 0
        questionLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(questionLabel)
        
        // Setup arrow image
        arrowImageView.contentMode = .scaleAspectFit
        arrowImageView.tintColor = .darkGray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        // Use system chevron image
        arrowImageView.image = UIImage(systemName: "chevron.down")
        containerView.addSubview(arrowImageView)
        
        // Setup answer label
        answerLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        answerLabel.textColor = .darkGray
        answerLabel.numberOfLines = 0
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(answerLabel)
        
        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        containerView.addGestureRecognizer(tapGesture)
        containerView.isUserInteractionEnabled = true
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 5),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -5),
            
            // Question label constraints
            questionLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            questionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            questionLabel.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -8),
            
            // Arrow image constraints
            arrowImageView.centerYAnchor.constraint(equalTo: questionLabel.centerYAnchor),
            arrowImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20),
            
            // Answer label constraints - will be updated based on expanded state
            answerLabel.topAnchor.constraint(equalTo: questionLabel.bottomAnchor, constant: 8),
            answerLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            answerLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            answerLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12)
        ])
        
        // Initial state
        answerLabel.isHidden = true
    }
    
    // MARK: - Actions
    
    @objc private func handleTap() {
        delegate?.didTapFAQ(at: index)
    }
    
    func updateExpandedState() {
        // Update UI based on expanded state
        answerLabel.isHidden = !isExpanded
        
        // Rotate arrow
        UIView.animate(withDuration: 0.3) {
            self.arrowImageView.transform = self.isExpanded ? 
                CGAffineTransform(rotationAngle: .pi) : .identity
        }
    }
}
