//
//  PreBookingCalendarView.swift
//  iKisanApp
//
//  UICalendarView wrapper for SwiftUI that displays colored dot decorations:
//    🟢 Green  = Searched equipment is available on this date
//    🔵 Blue   = User already has a booking on this date
//    🟣 Purple = Both: booking exists AND searched equipment is available
//
//  Uses UIViewRepresentable to access UICalendarView's decoration API (iOS 16+).
//

import SwiftUI
import UIKit

struct PreBookingCalendarView: UIViewRepresentable {
    
    /// Equipment to check availability against (the searched group)
    var searchedEquipments: [Equipment]
    
    /// Dates that already have user bookings
    var bookingDates: Set<Date>
    
    /// Currently selected date (binding)
    @Binding var selectedDate: Date
    
    /// Called when user taps a date
    var onDateSelected: (Date) -> Void
    
    func makeUIView(context: Context) -> UICalendarView {
        let calendarView = UICalendarView()
        let gregorianCalendar = Calendar(identifier: .gregorian)
        calendarView.calendar = gregorianCalendar
        calendarView.tintColor = UIColor.ikisanGreen
        calendarView.fontDesign = .rounded
        calendarView.backgroundColor = .clear
        
        // Remove excess internal padding
        calendarView.layoutMargins = UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)
        
        // Don't clip — let the decorations render naturally
        calendarView.clipsToBounds = false
        
        // Date range: today → 1 year out
        calendarView.availableDateRange = DateInterval(
            start: Date(),
            end: Date().addingTimeInterval(365 * 24 * 60 * 60)
        )
        
        // Default selection = today
        let todayComponents = gregorianCalendar.dateComponents([.year, .month, .day], from: Date())
        let selection = UICalendarSelectionSingleDate(delegate: context.coordinator)
        selection.selectedDate = todayComponents
        calendarView.selectionBehavior = selection
        calendarView.visibleDateComponents = todayComponents
        
        calendarView.delegate = context.coordinator
        
        // Let auto-layout size it
        calendarView.setContentCompressionResistancePriority(.required, for: .vertical)
        calendarView.setContentHuggingPriority(.required, for: .vertical)
        
        return calendarView
    }
    
    func updateUIView(_ calendarView: UICalendarView, context: Context) {
        // Update coordinator's data
        context.coordinator.searchedEquipments = searchedEquipments
        context.coordinator.bookingDates = bookingDates
        
        // Refresh decorations for the visible month
        refreshDecorations(for: calendarView)
    }
    
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UICalendarView, context: Context) -> CGSize? {
        // Let UICalendarView calculate its own intrinsic height
        let targetWidth = proposal.width ?? UIScreen.main.bounds.width - 32
        let fittingSize = uiView.systemLayoutSizeFitting(
            CGSize(width: targetWidth, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return fittingSize
    }
    
    private func refreshDecorations(for calendarView: UICalendarView) {
        let calendar = Calendar.current
        let visible = calendarView.visibleDateComponents
        
        guard let visibleDate = calendar.date(from: visible),
              let range = calendar.range(of: .day, in: .month, for: visibleDate) else { return }
        
        var componentsToRefresh = Set<DateComponents>()
        
        for day in range {
            var components = visible
            components.day = day
            if let dayDate = calendar.date(from: components) {
                let dc = calendar.dateComponents([.year, .month, .day], from: calendar.startOfDay(for: dayDate))
                componentsToRefresh.insert(dc)
            }
        }
        
        // Also refresh booking dates and today
        for d in bookingDates {
            componentsToRefresh.insert(calendar.dateComponents([.year, .month, .day], from: d))
        }
        componentsToRefresh.insert(calendar.dateComponents([.year, .month, .day], from: Date()))
        
        DispatchQueue.main.async {
            calendarView.reloadDecorations(forDateComponents: Array(componentsToRefresh), animated: false)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // MARK: - Coordinator
    
    class Coordinator: NSObject, UICalendarViewDelegate, UICalendarSelectionSingleDateDelegate {
        var parent: PreBookingCalendarView
        var searchedEquipments: [Equipment] = []
        var bookingDates: Set<Date> = []
        
        init(_ parent: PreBookingCalendarView) {
            self.parent = parent
            self.searchedEquipments = parent.searchedEquipments
            self.bookingDates = parent.bookingDates
        }
        
        // MARK: - Decorations
        
        func calendarView(
            _ calendarView: UICalendarView,
            decorationFor dateComponents: DateComponents
        ) -> UICalendarView.Decoration? {
            guard let date = Calendar.current.date(from: dateComponents) else { return nil }
            let startOfDay = Calendar.current.startOfDay(for: date)
            let today = Calendar.current.startOfDay(for: Date())
            
            // No decoration for past dates
            guard startOfDay >= today else { return nil }
            
            let hasBooking = bookingDates.contains(startOfDay)
            let isEquipmentAvailable = !searchedEquipments.isEmpty && searchedEquipments.contains { $0.isAvailable(on: date) }
            
            // Purple: both booking AND equipment available
            if hasBooking && isEquipmentAvailable {
                return .default(color: .systemPurple, size: .medium)
            }
            
            // Blue: user already has a booking
            if hasBooking {
                return .default(color: .systemBlue, size: .medium)
            }
            
            // Green: searched equipment available
            if isEquipmentAvailable {
                return .default(color: UIColor.ikisanGreen, size: .medium)
            }
            
            return nil
        }
        
        func calendarView(
            _ calendarView: UICalendarView,
            didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents
        ) {
            parent.refreshDecorations(for: calendarView)
        }
        
        // MARK: - Selection
        
        func dateSelection(
            _ selection: UICalendarSelectionSingleDate,
            didSelectDate dateComponents: DateComponents?
        ) {
            guard let dateComponents = dateComponents,
                  let date = Calendar.current.date(from: dateComponents) else { return }
            
            let startOfDay = Calendar.current.startOfDay(for: date)
            let today = Calendar.current.startOfDay(for: Date())
            
            guard startOfDay >= today else { return }
            
            parent.selectedDate = date
            parent.onDateSelected(date)
        }
        
        func dateSelection(
            _ selection: UICalendarSelectionSingleDate,
            canSelectDate dateComponents: DateComponents?
        ) -> Bool {
            guard let dateComponents = dateComponents,
                  let date = Calendar.current.date(from: dateComponents) else { return false }
            
            return Calendar.current.startOfDay(for: date) >= Calendar.current.startOfDay(for: Date())
        }
    }
}
