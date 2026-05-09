//
//  PaymentMethodRow.swift
//  iKisanApp
//
//  HIG-compliant payment method selection row.
//  Used in the Review Booking checkout flow.
//

import SwiftUI

/// A selectable row displaying a payment method option.
/// Follows Apple HIG with SF Symbols, semantic typography, and native radio-style selection.
struct PaymentMethodRow: View {
    let method: PaymentMethod
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            onSelect()
        }) {
            HStack(spacing: 14) {
                // Selection indicator (radio-style)
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? .ikisanGreen : .gray.opacity(0.4))
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
                
                // Payment method icon
                Image(systemName: method.iconName)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .ikisanGreen : .secondary)
                    .frame(width: 28, height: 28)
                
                // Text content
                VStack(alignment: .leading, spacing: 3) {
                    Text(method.displayName)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    Text(method.subtitle)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(isSelected
                          ? Color.ikisanGreen.opacity(0.08)
                          : Color(UIColor.tertiarySystemGroupedBackground))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        isSelected ? Color.ikisanGreen.opacity(0.4) : Color.clear,
                        lineWidth: 1.5
                    )
            )
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(method.displayName): \(method.subtitle)")
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
    }
}

// MARK: - Preview

#if DEBUG
struct PaymentMethodRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 12) {
            PaymentMethodRow(
                method: .cashOnDelivery,
                isSelected: true,
                onSelect: {}
            )
            PaymentMethodRow(
                method: .razorpay,
                isSelected: false,
                onSelect: {}
            )
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }
}
#endif
