// Extension to PrebookingViewController to handle FAQ interactions
import UIKit

extension PrebookingViewController: FAQCellDelegate {
    
    // Implementation of the delegate method for handling FAQ taps
    func didTapFAQ(at index: Int) {
        // Toggle the expanded state of the tapped FAQ
        if expandedFAQIndices.contains(index) {
            expandedFAQIndices.remove(index)
        } else {
            expandedFAQIndices.insert(index)
        }
        
        // Reload just the FAQ section to update the UI
        let sectionIndex = getSectionIndex(for: Section.faq)
        collectionView.reloadSections(IndexSet(integer: sectionIndex))
    }
}
