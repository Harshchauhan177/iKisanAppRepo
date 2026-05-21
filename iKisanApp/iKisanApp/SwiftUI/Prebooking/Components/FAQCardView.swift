//
//  FAQCardView.swift
//  iKisanApp
//
//  iOS Settings-style FAQ list item with question text and chevron disclosure.
//  Used in the Pre Booking landing screen's "FAQ" section.
//

import SwiftUI

struct FAQCardView: View {
    let faq: FAQ
    let isFirst: Bool
    let isLast: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    // Question Text
                    Text(faq.question)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Chevron
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(.systemGray2))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
                
                // Separator (hidden for last item)
                if !isLast {
                    Divider()
                        .padding(.leading, 16)
                }
            }
            .background(Color(.systemBackground))
        }
        .buttonStyle(.plain)
        .clipShape(
            UnevenRoundedRectangle(
                topLeadingRadius: isFirst ? 10 : 0,
                bottomLeadingRadius: isLast ? 10 : 0,
                bottomTrailingRadius: isLast ? 10 : 0,
                topTrailingRadius: isFirst ? 10 : 0
            )
        )
        .accessibilityLabel(faq.question)
        .accessibilityHint("Double tap to view answer")
        .accessibilityAddTraits(.isButton)
    }
}

// MARK: - Preview
#if DEBUG
struct FAQCardView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            FAQCardView(
                faq: FAQ(id: UUID(), question: "What is Pre Booking?", answer: "Pre-booking allows you to reserve equipment in advance."),
                isFirst: true,
                isLast: false,
                onTap: {}
            )
            FAQCardView(
                faq: FAQ(id: UUID(), question: "How do I cancel?", answer: "You can cancel from your prebookings section."),
                isFirst: false,
                isLast: false,
                onTap: {}
            )
            FAQCardView(
                faq: FAQ(id: UUID(), question: "What is the refund policy?", answer: "Full refund within 24 hours."),
                isFirst: false,
                isLast: true,
                onTap: {}
            )
        }
        .padding(.horizontal, 16)
        .background(Color(.systemGroupedBackground))
        .previewLayout(.sizeThatFits)
    }
}
#endif
