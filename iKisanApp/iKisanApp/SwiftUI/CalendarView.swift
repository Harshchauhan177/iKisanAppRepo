//
//  CalendarView.swift
//  iKisanApp
//
//  Created on 30/12/25.
//

import SwiftUI

struct CalendarView: View {
    let availableEquipments: [Equipment]
    let prebookingDates: [Date]
    let onDateSelected: (Date) -> Void
    
    @State private var selectedDate: Date = Date()
    @State private var displayedMonth: Date = Date()
    
    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 8), count: 7)
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: displayedMonth)
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: displayedMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start) else {
            return []
        }
        
        var dates: [Date?] = []
        var currentDate = monthFirstWeek.start
        
        while dates.count < 42 { // 6 weeks * 7 days
            if calendar.isDate(currentDate, equalTo: displayedMonth, toGranularity: .month) {
                dates.append(currentDate)
            } else {
                dates.append(nil)
            }
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return dates
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Month/Year Header with Navigation
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                }
            }
            .padding(.horizontal)
            
            // Weekday Headers
            HStack(spacing: 8) {
                ForEach(["S", "M", "T", "W", "T", "F", "S"], id: \.self) { day in
                    Text(day)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            // Calendar Grid
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(daysInMonth.indices, id: \.self) { index in
                    if let date = daysInMonth[index] {
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            isToday: calendar.isDateInToday(date),
                            hasPreBooking: hasPreBooking(on: date),
                            isAvailable: isEquipmentAvailable(on: date),
                            isPast: date < calendar.startOfDay(for: Date())
                        )
                        .onTapGesture {
                            if date >= calendar.startOfDay(for: Date()) {
                                selectedDate = date
                                onDateSelected(date)
                            }
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .onAppear {
            selectedDate = Date()
        }
    }
    
    private func previousMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: -1, to: displayedMonth) else { return }
        displayedMonth = newMonth
    }
    
    private func nextMonth() {
        guard let newMonth = calendar.date(byAdding: .month, value: 1, to: displayedMonth) else { return }
        displayedMonth = newMonth
    }
    
    private func hasPreBooking(on date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        return prebookingDates.contains(where: { calendar.isDate($0, inSameDayAs: startOfDay) })
    }
    
    private func isEquipmentAvailable(on date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        return availableEquipments.contains { equipment in
            equipment.isAvailable(on: startOfDay)
        }
    }
}

// MARK: - Calendar Day View

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let hasPreBooking: Bool
    let isAvailable: Bool
    let isPast: Bool
    
    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color(red: 0.298, green: 0.498, blue: 0.345)
        } else if isToday {
            return Color(red: 0.298, green: 0.498, blue: 0.345).opacity(0.2)
        } else {
            return Color.clear
        }
    }
    
    private var textColor: Color {
        if isPast {
            return .gray.opacity(0.4)
        } else if isSelected {
            return .white
        } else {
            return .primary
        }
    }
    
    private var decorationColor: Color? {
        if hasPreBooking && isAvailable {
            return .purple
        } else if hasPreBooking {
            return .blue
        } else if isAvailable {
            return Color(red: 0.298, green: 0.498, blue: 0.345)
        } else {
            return nil
        }
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(dayNumber)
                .font(.system(size: 16))
                .foregroundColor(textColor)
                .frame(width: 36, height: 36)
                .background(backgroundColor)
                .cornerRadius(18)
            
            if let color = decorationColor, !isPast {
                Circle()
                    .fill(color)
                    .frame(width: 6, height: 6)
            } else {
                Color.clear
                    .frame(width: 6, height: 6)
            }
        }
        .frame(height: 48)
    }
}
