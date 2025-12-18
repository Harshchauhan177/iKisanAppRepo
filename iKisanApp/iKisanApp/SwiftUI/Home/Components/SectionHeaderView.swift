//
//  SectionHeaderView.swift
//  iKisanApp
//
//  SwiftUI Component for Section Headers
//

import SwiftUI

struct SectionHeaderView: View {
    let title: String
    var showViewAll: Bool = false
    var onViewAllTapped: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.primary)
            
            Spacer()
            
            if showViewAll {
                Button(action: {
                    onViewAllTapped?()
                }) {
                    HStack(spacing: 4) {
                        Text("View All")
                            .font(.system(size: 15, weight: .semibold))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 4)
    }
}

// MARK: - Preview
#if DEBUG
struct SectionHeaderView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SectionHeaderView(title: "Discounts")
            
            SectionHeaderView(
                title: "Upcoming Bookings",
                showViewAll: true,
                onViewAllTapped: {}
            )
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
#endif
