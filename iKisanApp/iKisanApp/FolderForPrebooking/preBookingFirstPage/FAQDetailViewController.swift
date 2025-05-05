//
//  FAQDetailViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 05/05/25.
//

import UIKit

class FAQDetailViewController: UIViewController {
    
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let titleLabel = UILabel()
    private let answerLabel = UILabel()
    
    // Data
    var faq: FAQ?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithFAQ()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // View setup
        view.backgroundColor = .systemGroupedBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)
        
        // Setup content view
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)
        
        // Setup title label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        contentView.addSubview(titleLabel)
        
        // Setup answer label
        answerLabel.translatesAutoresizingMaskIntoConstraints = false
        answerLabel.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        answerLabel.textColor = .label
        answerLabel.numberOfLines = 0
        contentView.addSubview(answerLabel)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Content view constraints
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Title label constraints
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            // Answer label constraints
            answerLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            answerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            answerLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            answerLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    // MARK: - Configuration
    
    private func configureWithFAQ() {
        guard let faq = faq else { return }
        
        // Set the navigation title with standard style
        title = "FAQ"
        navigationItem.largeTitleDisplayMode = .never
        
        // Configure labels
        titleLabel.text = faq.question
        answerLabel.text = faq.answer
    }
}
