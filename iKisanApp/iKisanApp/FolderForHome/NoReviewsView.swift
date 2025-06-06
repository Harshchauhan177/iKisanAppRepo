//
//  NoReviewsView.swift
//  iKisanApp
//
//  Created by System on 27/05/2024.
//

import UIKit

class NoReviewsView: UIView {
    
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let writeReviewButton = UIButton(type: .system)
    
    var onWriteReviewTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        backgroundColor = .systemBackground
        
        // Container View
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)
        
        // Icon Image View
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        iconImageView.image = UIImage(systemName: "star.slash")
        containerView.addSubview(iconImageView)
        
        // Title Label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.text = "No Reviews Yet"
        containerView.addSubview(titleLabel)
        
        // Description Label
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textColor = .secondaryLabel
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 0
        descriptionLabel.text = "Be the first to share your experience with this equipment."
        containerView.addSubview(descriptionLabel)
        
        // Write Review Button
        writeReviewButton.translatesAutoresizingMaskIntoConstraints = false
        writeReviewButton.setTitle("Write a Review", for: .normal)
        writeReviewButton.backgroundColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        writeReviewButton.setTitleColor(.white, for: .normal)
        writeReviewButton.layer.cornerRadius = 8
        writeReviewButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        writeReviewButton.addTarget(self, action: #selector(writeReviewTapped), for: .touchUpInside)
        containerView.addSubview(writeReviewButton)
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // Container View
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            // Icon Image View
            iconImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            iconImageView.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 50),
            iconImageView.heightAnchor.constraint(equalToConstant: 50),
            
            // Title Label
            titleLabel.topAnchor.constraint(equalTo: iconImageView.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Description Label
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            
            // Write Review Button
            writeReviewButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            writeReviewButton.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            writeReviewButton.widthAnchor.constraint(equalToConstant: 160),
            writeReviewButton.heightAnchor.constraint(equalToConstant: 40),
            writeReviewButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }
    
    @objc private func writeReviewTapped() {
        onWriteReviewTapped?()
    }
    
    // Function to update UI based on user authorization status
    func configure(canUserWriteReview: Bool, message: String? = nil) {
        if let customMessage = message {
            descriptionLabel.text = customMessage
        } else {
            descriptionLabel.text = canUserWriteReview ? 
                "Be the first to share your experience with this equipment." : 
                "You need to book and use this equipment before writing a review."
        }
        
        writeReviewButton.isHidden = !canUserWriteReview
    }
} 