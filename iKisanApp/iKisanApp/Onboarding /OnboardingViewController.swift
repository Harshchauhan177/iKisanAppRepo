import UIKit

class OnboardingViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var skipBtn: UIButton!
    
    var slides: [OnboardingSlide] = []
    
    var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
            updateUIForCurrentPage()
        }
    }
    
    private func updateUIForCurrentPage() {
        let isLastPage = currentPage == slides.count - 1
        
        // Update button title
        nextBtn.setTitle(isLastPage ? "Get Started" : "Next", for: .normal)
        
        // Update skip button visibility with animation
        UIView.animate(withDuration: 0.3) {
            self.skipBtn.alpha = isLastPage ? 0 : 1
        } completion: { _ in
            self.skipBtn.isHidden = isLastPage
        }
        
        // Update accessibility
        nextBtn.accessibilityLabel = isLastPage ? "Get Started" : "Next"
        nextBtn.accessibilityHint = isLastPage ? "Complete onboarding and start using iKisan" : "Go to next slide"
        pageControl.accessibilityLabel = "Page \(self.currentPage + 1) of \(self.slides.count)"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupSlides()
        setupCollectionView()
        setupAccessibility()
        
        // Set initial skip button state
        skipBtn.isHidden = (currentPage == slides.count - 1)
    }
    
    private func setupUI() {
        // Set background color with dark mode support
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
        
        // Button styling
        nextBtn.layer.cornerRadius = 12
        nextBtn.clipsToBounds = true
        
        // Make page control interactive
        pageControl.isUserInteractionEnabled = true
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        // Update UI when switching between light/dark mode
        if traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateColorsForCurrentTraitCollection()
        }
    }
    
    private func updateColorsForCurrentTraitCollection() {
        // Update background colors for dark mode
        view.backgroundColor = .systemBackground
        collectionView.backgroundColor = .systemBackground
    }
    
    private func setupSlides() {
        slides = [
            OnboardingSlide(title: "Find Equipments", description: "Find the best Equipments as service nearby your locality.", image: UIImage(named: "on1") ?? UIImage(), logo: UIImage(systemName: "magnifyingglass")),
            OnboardingSlide(title: "Co-Equip", description: "Team up with other users who need the same equipment for shared services.", image: UIImage(named: "on2") ?? UIImage(), logo: UIImage(systemName: "person.3.fill")),
            OnboardingSlide(title: "AgriAssist", description: "Find the best equipment for your agricultural needs.", image: UIImage(named: "on3") ?? UIImage(), logo: UIImage(systemName: "lightbulb.max.fill"))
        ]
    }
    
    private func setupCollectionView() {
        registerCells()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
    }
    
    private func setupAccessibility() {
        // Accessibility for Next/Get Started button
        nextBtn.accessibilityLabel = currentPage == slides.count - 1 ? "Get Started" : "Next"
        nextBtn.accessibilityHint = currentPage == slides.count - 1 ? "Complete onboarding and start using iKisan" : "Go to next slide"
        
        // Accessibility for Skip button
        skipBtn.accessibilityLabel = "Skip"
        skipBtn.accessibilityHint = "Skip onboarding and start using iKisan"
        
        // Accessibility for Page Control
        pageControl.accessibilityLabel = "Page \(currentPage + 1) of \(slides.count)"
        pageControl.accessibilityHint = "Swipe left or right to navigate between slides"
    }
    
    @objc private func pageControlTapped(_ sender: UIPageControl) {
        let page = sender.currentPage
        currentPage = page
        let indexPath = IndexPath(item: page, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func registerCells() {
        collectionView.register(UINib(nibName: OnboardingCollectionViewCell.identifier, bundle: nil), forCellWithReuseIdentifier: OnboardingCollectionViewCell.identifier)
    }
    
    @IBAction func skipBtnClicked(_ sender: Any) {
        completeOnboarding()
    }
    
    @IBAction func nextBtnClicked(_ sender: Any) {
        if currentPage == slides.count - 1 {
            completeOnboarding()
        } else {
            currentPage += 1
            let indexPath = IndexPath(item: currentPage, section: 0)
            collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    /// Marks onboarding as complete and transitions to the main interface.
    private func completeOnboarding() {
        // Note: We don't mark onboarding as completed here anymore since it will be done after crop selection
        
        // Call the SceneDelegate helper to switch to crop selection
        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.switchToMainInterface()
        }
    }
}

extension OnboardingViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return slides.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OnboardingCollectionViewCell.identifier, for: indexPath) as! OnboardingCollectionViewCell
        
        cell.setup(slides[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
}
