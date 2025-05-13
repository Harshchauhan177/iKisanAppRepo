//
//  PreBookingSectionHeaderCollectionReusableView.swift
//  iKisanApp
//
//  Created by Batch - 1 on 23/01/25.
//

import UIKit

class PreBookingSectionHeaderCollectionReusableView: UICollectionReusableView {
        
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
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure Dynamic Text support
        headerLabel.adjustsFontForContentSizeCategory = true
        let headerFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: headerFont)
        
        // Register for content size category changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
        
        addSubview(headerLabel)
//        addSubview(button)
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
                                    
//            button.topAnchor.constraint(equalTo: topAnchor),
//            button.bottomAnchor.constraint(equalTo: bottomAnchor),
//            button.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 300),
        ])
    }
    
    @objc private func contentSizeCategoryDidChange() {
        // Update font when text size settings change
        let headerFont = UIFont.systemFont(ofSize: 18, weight: .bold)
        headerLabel.font = UIFontMetrics(forTextStyle: .headline).scaledFont(for: headerFont)
        setNeedsLayout()
    }
    
    deinit {
        // Remove notification observer when view is deallocated
        NotificationCenter.default.removeObserver(self)
    }
}
