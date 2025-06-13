//
//  SectionHeaderCollectionReusableView.swift
//  iKisanApp
//
//  Created by Batch - 2 on 16/01/25.
//

import UIKit

class SectionHeaderCollectionReusableView: UICollectionReusableView {
    
    var headerLabel = UILabel()
    var button = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateSectionHeader()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        updateSectionHeader()
    }
    
    func updateSectionHeader() {
        // Configure header label
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        headerLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerLabel.textColor = .black
        
        // Configure button
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)

        addSubview(headerLabel)
        addSubview(button)
        
        // Updated constraints for consistent alignment
        NSLayoutConstraint.activate([
            // Header label constraints - aligned to the left edge consistently
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            headerLabel.trailingAnchor.constraint(lessThanOrEqualTo: button.leadingAnchor, constant: -8),
            
            // Button constraints - aligned to the right
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 30),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
}
