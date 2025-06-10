import UIKit

class AllReviewsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: - Properties
    
    var equipment: Equipment?
    var reviews: [ReviewData] = [] {
        didSet {
            if isViewLoaded {
                tableView.reloadData()
                updateEmptyState()
            }
        }
    }
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let table = UITableView(frame: .zero, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.backgroundColor = .systemBackground
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 160
        table.register(AllReviewTableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    private lazy var emptyStateLabel: UILabel = {
        let label = UILabel()
        label.text = "No reviews yet for this equipment."
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .gray
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // Register the cell class for UITableView
        tableView.register(AllReviewTableViewCell.self, forCellReuseIdentifier: "ReviewCell")
        
        // Update the empty state
        updateEmptyState()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        // Set up theme colors
        let themeColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
        let bgColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        
        view.backgroundColor = bgColor
        title = "All Reviews"
        
        // Style navigation bar
        if #available(iOS 15.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor.darkText]
            appearance.shadowColor = .lightGray
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.tintColor = themeColor
        } else {
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = themeColor
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.darkText]
        }
        
        // Add table view with improved styling
        tableView.backgroundColor = bgColor
        tableView.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        // Style empty state label
        emptyStateLabel.textColor = .darkGray
        emptyStateLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        emptyStateLabel.text = "No reviews yet for this equipment."
        emptyStateLabel.textAlignment = .center
        
        // Add empty state label
        view.addSubview(emptyStateLabel)
        NSLayoutConstraint.activate([
            emptyStateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func updateEmptyState() {
        // Show empty state if no reviews
        emptyStateLabel.isHidden = !reviews.isEmpty
        tableView.isHidden = reviews.isEmpty
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reviews.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReviewCell", for: indexPath) as! AllReviewTableViewCell
        let review = reviews[indexPath.row]
        cell.configure(with: review)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard let equipment = equipment else { return nil }
        let averageRating = reviews.reduce(0.0) { $0 + $1.rating } / Double(reviews.count)
        return "\(equipment.name): \(String(format: "%.1f", averageRating)) ★ (\(reviews.count) reviews)"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let equipment = equipment, !reviews.isEmpty else { return nil }
        
        let headerView = UIView()
        headerView.backgroundColor = UIColor(red: 244/255, green: 244/255, blue: 244/255, alpha: 1.0)
        
        // Calculate average rating
        let averageRating = reviews.reduce(0.0) { $0 + $1.rating } / Double(reviews.count)
        
        // Equipment name label
        let nameLabel = UILabel()
        nameLabel.text = equipment.name
        nameLabel.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        nameLabel.textColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Rating info horizontal stack
        let ratingStack = UIStackView()
        ratingStack.axis = .horizontal
        ratingStack.spacing = 4
        ratingStack.alignment = .center
        ratingStack.translatesAutoresizingMaskIntoConstraints = false
        
        // Rating label
        let ratingLabel = UILabel()
        ratingLabel.text = String(format: "%.1f", averageRating)
        ratingLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        ratingLabel.textColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
        
        // Star image
        let starImage = UIImageView(image: UIImage(systemName: "star.fill"))
        starImage.tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
        starImage.contentMode = .scaleAspectFit
        starImage.widthAnchor.constraint(equalToConstant: 18).isActive = true
        starImage.heightAnchor.constraint(equalToConstant: 18).isActive = true
        
        // Reviews count label
        let reviewsCountLabel = UILabel()
        reviewsCountLabel.text = "(\(reviews.count) \(reviews.count == 1 ? "review" : "reviews"))"
        reviewsCountLabel.font = UIFont.systemFont(ofSize: 14)
        reviewsCountLabel.textColor = .darkGray
        
        // Add components to stack
        ratingStack.addArrangedSubview(ratingLabel)
        ratingStack.addArrangedSubview(starImage)
        ratingStack.addArrangedSubview(reviewsCountLabel)
        
        // Add to header view
        headerView.addSubview(nameLabel)
        headerView.addSubview(ratingStack)
        
        // Add separator line
        let separatorLine = UIView()
        separatorLine.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        separatorLine.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(separatorLine)
        
        NSLayoutConstraint.activate([
            // Name label constraints
            nameLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            // Rating stack
            ratingStack.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            ratingStack.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            
            // Separator line
            separatorLine.topAnchor.constraint(equalTo: ratingStack.bottomAnchor, constant: 16),
            separatorLine.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            separatorLine.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            separatorLine.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            separatorLine.heightAnchor.constraint(equalToConstant: 1)
        ])
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return reviews.isEmpty ? 0 : 100
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

// MARK: - Review Cell

class AllReviewTableViewCell: UITableViewCell {
    
    // MARK: - UI Elements
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let ratingView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 4
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let ratingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let starImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "star.fill"))
        imageView.tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        return imageView
    }()
    
    private let headingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .darkGray
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCell() {
        selectionStyle = .none
        backgroundColor = .clear
        
        // Set up view hierarchy
        contentView.addSubview(containerView)
        
        // Set up rating view with label and star
        ratingView.addArrangedSubview(ratingLabel)
        ratingView.addArrangedSubview(starImageView)
        
        containerView.addSubview(ratingView)
        containerView.addSubview(headingLabel)
        containerView.addSubview(descriptionLabel)
        
        // Add shadow to container view
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowOpacity = 0.1
        containerView.layer.masksToBounds = false
        
        NSLayoutConstraint.activate([
            // Container view constraints
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            // Rating view constraints
            ratingView.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            ratingView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            // Heading label constraints
            headingLabel.topAnchor.constraint(equalTo: ratingView.bottomAnchor, constant: 12),
            headingLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            headingLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            // Description label constraints
            descriptionLabel.topAnchor.constraint(equalTo: headingLabel.bottomAnchor, constant: 10),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            descriptionLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16)
        ])
    }
    
    // MARK: - Configuration
    
    func configure(with review: ReviewData) {
        // Format rating to show one decimal place
        ratingLabel.text = String(format: "%.1f", review.rating)
        
        // Update star color based on rating
        let themeColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1.0)
        starImageView.tintColor = themeColor
        
        // Set heading with semibold weight
        headingLabel.text = review.reviewHeading
        
        // Set description
        descriptionLabel.text = review.reviewDescription
        
        // Apply appropriate styling based on content
        if review.reviewDescription.isEmpty {
            descriptionLabel.isHidden = true
            headingLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16).isActive = true
        } else {
            descriptionLabel.isHidden = false
        }
    }
} 