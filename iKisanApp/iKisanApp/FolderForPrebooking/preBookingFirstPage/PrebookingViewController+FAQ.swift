// Extension to PrebookingViewController to handle FAQ interactions
import UIKit

extension PrebookingViewController: FAQCellDelegate {
    
    // Implementation of the delegate method for handling FAQ taps
    func didTapFAQ(at index: Int) {
        // Get the FAQ item
        guard index < faqs.count else { return }
        let faq = faqs[index]
        
        // Create and configure the detail view controller
        let detailVC = FAQDetailViewController()
        detailVC.faq = faq
        
        // Present the detail view controller
        navigationController?.pushViewController(detailVC, animated: true)
    }
}
