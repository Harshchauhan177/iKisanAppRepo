//
//  FAQDetailView.swift
//  iKisanApp
//
//  SwiftUI replacement for FAQDetailViewController.
//  Displays FAQ question and answer in a grouped card layout.
//

import SwiftUI

struct FAQDetailView: View {
    let faq: FAQ
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // Card Container
                VStack(alignment: .leading, spacing: 0) {
                    // Question
                    Text(faq.question)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(16)
                    
                    // Separator
                    Divider()
                    
                    // Answer
                    Text(faq.answer)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                        .lineSpacing(4)
                        .padding(16)
                }
                .background(Color(.systemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                .padding(.horizontal, 16)
                .padding(.top, 16)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Help")
        .navigationBarTitleDisplayMode(.inline)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Preview
#if DEBUG
struct FAQDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            FAQDetailView(
                faq: FAQ(
                    id: UUID(),
                    question: "What is Pre Booking?",
                    answer: "Pre-booking allows you to reserve agricultural equipment well in advance of your farming season. This ensures that the equipment you need will be available exactly when you need it, avoiding last-minute availability issues during peak seasons.\n\nYou can pre-book equipment for specific dates and the booking will be confirmed immediately."
                )
            )
        }
    }
}
#endif
