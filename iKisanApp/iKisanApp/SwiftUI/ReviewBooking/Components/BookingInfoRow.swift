//
//  BookingInfoRow.swift
//  iKisanApp
//
//  Reusable component for displaying booking information rows
//

import SwiftUI

/// A reusable row component for displaying booking information with an icon, title, and content
struct BookingInfoRow<Content: View>: View {
    let icon: String
    let title: String
    let content: Content
    let showChevron: Bool
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        showChevron: Bool = false,
        action: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.icon = icon
        self.title = title
        self.showChevron = showChevron
        self.action = action
        self.content = content()
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(alignment: .top, spacing: 12) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(.ikisanGreen)
                    .frame(width: 24, height: 24)
                    .accessibilityHidden(true)
                
                // Title and Content
                VStack(alignment: .leading, spacing: 8) {
                    Text(title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    content
                        .font(.system(size: 15))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Chevron indicator for interactive rows
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.gray.opacity(0.5))
                        .accessibilityHidden(true)
                }
            }
            .padding(.vertical, 12)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(action == nil)
    }
}

/// A reusable row component for input fields with an icon and title
struct BookingInputRow: View {
    let icon: String
    let title: String
    @Binding var text: String
    let placeholder: String
    let keyboardType: UIKeyboardType
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.ikisanGreen)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            
            // Title and Input
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                TextField(placeholder, text: $text)
                    .font(.system(size: 15))
                    .keyboardType(keyboardType)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("\(title) input field")
                    .accessibilityHint(placeholder)
            }
        }
        .padding(.vertical, 12)
    }
}

/// A reusable row component for field area input with unit picker
struct FieldAreaInputRow: View {
    let icon: String
    let title: String
    @Binding var text: String
    @Binding var selectedUnit: FieldAreaUnit
    let placeholder: String
    
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.ikisanGreen)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            
            // Title and Input
            VStack(alignment: .leading, spacing: 10) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                HStack(spacing: 10) {
                    // Text Field for area value
                    HStack {
                        TextField(placeholder, text: $text)
                            .font(.system(size: 16, weight: .medium))
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.leading)
                            .focused($isTextFieldFocused)
                            .accessibilityLabel("\(title) input field")
                            .accessibilityHint("Enter the numeric value for field area")
                        
                        // Clear button when text is entered
                        if !text.isEmpty {
                            Button(action: {
                                text = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(.gray.opacity(0.5))
                            }
                            .accessibilityLabel("Clear field area")
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(.systemGray6))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(
                                isTextFieldFocused ? Color.ikisanGreen : Color.clear,
                                lineWidth: 2
                            )
                    )
                    .frame(maxWidth: .infinity)
                    
                    // Enhanced Unit Picker with better visual design
                    Menu {
                        Picker("Unit", selection: $selectedUnit) {
                            ForEach(FieldAreaUnit.allCases, id: \.self) { unit in
                                HStack {
                                    Text(unit.displayName)
                                    if unit == selectedUnit {
                                        Image(systemName: "checkmark")
                                    }
                                }
                                .tag(unit)
                            }
                        }
                        .labelsHidden()
                    } label: {
                        HStack(spacing: 6) {
                            Text(selectedUnit.displayName)
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundColor(.ikisanGreen)
                            
                            Image(systemName: "chevron.up.chevron.down")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.ikisanGreen.opacity(0.7))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.ikisanGreenLight)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .strokeBorder(Color.ikisanGreen.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .accessibilityLabel("Unit: \(selectedUnit.displayName)")
                    .accessibilityHint("Double tap to change measurement unit")
                    .fixedSize()
                }
            }
        }
        .padding(.vertical, 12)
        .animation(.easeInOut(duration: 0.2), value: isTextFieldFocused)
    }
}

/// Time slot picker with up/down arrows
struct TimeSlotPicker: View {
    let icon: String
    let title: String
    @Binding var selectedTimeSlot: TimeSlot
    let timeSlots: [TimeSlot] = [.morning, .afternoon, .evening]
    
    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.ikisanGreen)
                .frame(width: 24, height: 24)
                .accessibilityHidden(true)
            
            // Title and Selected Value
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text(selectedTimeSlot.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        Capsule()
                            .fill(Color(.systemGray6))
                    )
            }
            
            Spacer()
            
            // Enhanced Up/Down arrows with better touch targets
            VStack(spacing: 8) {
                Button(action: {
                    selectPreviousTimeSlot()
                }) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.ikisanGreen)
                        .frame(width: 32, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.ikisanGreenLight)
                        )
                }
                .accessibilityLabel("Select previous time slot")
                
                Button(action: {
                    selectNextTimeSlot()
                }) {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.ikisanGreen)
                        .frame(width: 32, height: 24)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.ikisanGreenLight)
                        )
                }
                .accessibilityLabel("Select next time slot")
            }
        }
        .padding(.vertical, 12)
    }
    
    private func selectPreviousTimeSlot() {
        guard let currentIndex = timeSlots.firstIndex(of: selectedTimeSlot) else { return }
        let previousIndex = (currentIndex - 1 + timeSlots.count) % timeSlots.count
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        selectedTimeSlot = timeSlots[previousIndex]
    }
    
    private func selectNextTimeSlot() {
        guard let currentIndex = timeSlots.firstIndex(of: selectedTimeSlot) else { return }
        let nextIndex = (currentIndex + 1) % timeSlots.count
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        
        selectedTimeSlot = timeSlots[nextIndex]
    }
}

// MARK: - Preview Helpers

#if DEBUG
struct BookingInfoRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 0) {
            BookingInfoRow(
                icon: "mappin.circle.fill",
                title: "Location",
                showChevron: true,
                action: {}
            ) {
                Text("1-99 Stockton St, San Francisco, CA 941...")
                    .lineLimit(2)
            }
            
            Divider()
            
            FieldAreaInputRow(
                icon: "ruler.fill",
                title: "Your Field Area",
                text: .constant(""),
                selectedUnit: .constant(.acre),
                placeholder: "Enter field area"
            )
            
            Divider()
            
            TimeSlotPicker(
                icon: "clock.fill",
                title: "Time",
                selectedTimeSlot: .constant(.morning)
            )
        }
        .background(Color.cardBackground)
        .previewLayout(.sizeThatFits)
    }
}
#endif
