//
//  FAQDetailViewController.swift
//  iKisanApp
//
//  Created by Batch - 2 on 05/05/25.
//

import UIKit

class FAQDetailViewController: UIViewController {
    
    // UI Elements - Using iOS 15+ style inset grouped cards
    private let scrollView = UIScrollView()
    private let cardView = UIView() // Main container card
    private let titleLabel = UILabel()
    private let answerView = UITextView() // UITextView for better text rendering
    private let seperatorView = UIView() // iOS style seperator
    
    // Data
    var faq: FAQ?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithFAQ()
        setupDynamicTypeSupport()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // View setup - use system background color
        view.backgroundColor = .systemGroupedBackground
        
        // Setup scroll view
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 16, right: 0)
        view.addSubview(scrollView)
        
        // Setup card view with inset grouped style
        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .systemBackground
        cardView.layer.cornerRadius = 10
        // Add subtle shadow for depth
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.08
        cardView.layer.shadowOffset = CGSize(width: 0, height: 1)
        cardView.layer.shadowRadius = 3
        scrollView.addSubview(cardView)
        
        // Setup title label - iOS style heading
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0
        cardView.addSubview(titleLabel)
        
        // Setup seperator - standard iOS style
        seperatorView.translatesAutoresizingMaskIntoConstraints = false
        seperatorView.backgroundColor = .systemGray5
        cardView.addSubview(seperatorView)
        
        // Setup answer text view - better text handling than label
        answerView.translatesAutoresizingMaskIntoConstraints = false
        answerView.isEditable = false
        answerView.isScrollEnabled = false // Let the scroll view handle scrolling
        answerView.backgroundColor = .clear
        answerView.textContainer.lineFragmentPadding = 0 // Remove text insets
        answerView.textContainerInset = .zero
        answerView.textColor = .secondaryLabel // iOS styled secondary text
        cardView.addSubview(answerView)
        
        // Setup constraints
        NSLayoutConstraint.activate([
            // Scroll view constraints
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            // Card view constraints - inset from edges like iOS settings
            cardView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            cardView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            cardView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            cardView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32),
            
            // Title label constraints - standard iOS insets
            titleLabel.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            
            // Separator view
            seperatorView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            seperatorView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            seperatorView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            seperatorView.heightAnchor.constraint(equalToConstant: 0.5), // Thin separator line
            
            // Answer view constraints
            answerView.topAnchor.constraint(equalTo: seperatorView.bottomAnchor, constant: 16),
            answerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            answerView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            answerView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])
    }
    
    private func setupDynamicTypeSupport() {
        // Register for content size category changes
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(contentSizeCategoryDidChange),
            name: UIContentSizeCategory.didChangeNotification,
            object: nil
        )
        
        // Apply dynamic type
        applyDynamicTextStyles()
    }
    
    private func applyDynamicTextStyles() {
        // Title - use system font with dynamic type (iOS style)
        titleLabel.adjustsFontForContentSizeCategory = true
        let titleFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.font = UIFontMetrics(forTextStyle: .title3).scaledFont(for: titleFont)
        
        // Answer - use system font with dynamic type
        answerView.adjustsFontForContentSizeCategory = true
        let bodyFont = UIFont.systemFont(ofSize: 17, weight: .regular)
        answerView.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: bodyFont)
    }
    
    @objc private func contentSizeCategoryDidChange() {
        // Refresh fonts when text size settings change
        applyDynamicTextStyles()
        view.setNeedsLayout()
    }
    
    // MARK: - Configuration
    
    private func configureWithFAQ() {
        guard let faq = faq else { return }
        
        // Set the navigation title with iOS style
        title = "Help" // More standard iOS terminology
        navigationItem.largeTitleDisplayMode = .never
        
        // Add a Done button if this is presented modally (iOS style)
        if presentingViewController != nil && navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .done,
                target: self,
                action: #selector(dismissViewController)
            )
        }
        
        // Configure labels with content
        titleLabel.text = faq.question
        answerView.text = faq.answer
    }
    
    @objc private func dismissViewController() {
        dismiss(animated: true)
    }
    
    deinit {
        // Remove observer when view controller is deallocated
        NotificationCenter.default.removeObserver(self)
    }
}
