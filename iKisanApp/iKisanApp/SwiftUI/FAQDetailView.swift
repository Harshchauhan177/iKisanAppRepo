//
//  FAQDetailView.swift
//  iKisanApp
//
//  Created on 30/12/25.
//

import SwiftUI

struct FAQDetailView: View {
    let faq: FAQ
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Question
                    Text(faq.question)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Divider()
                    
                    // Answer
                    Text(faq.answer)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(color: Color.black.opacity(0.08), radius: 3, x: 0, y: 1)
                .padding()
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Help")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
