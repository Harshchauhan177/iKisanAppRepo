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
        headerLabel.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .init(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)

        addSubview(headerLabel)
        addSubview(button)
        
        
        NSLayoutConstraint.activate([
            headerLabel.topAnchor.constraint(equalTo: topAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor,constant: 16),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            
       
            button.topAnchor.constraint(equalTo: topAnchor),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
            button.trailingAnchor.constraint(equalTo: trailingAnchor),
            button.leadingAnchor.constraint(equalTo: leadingAnchor,constant : 300)
        ])
    }
        
}
