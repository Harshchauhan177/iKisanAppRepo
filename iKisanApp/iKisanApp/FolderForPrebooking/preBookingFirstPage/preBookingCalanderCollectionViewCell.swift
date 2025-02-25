//
//  preBookingEquipmentSection2CollectionViewCell.swift
//  iKisanApp
//
//  Created by Batch - 1 on 23/01/25.
//

import UIKit

class preBookingCalanderCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var preBookingDatePicker: UIDatePicker!
    private var calendarView: UICalendarView?
    
    var dataController: DataController?
    private var availableEquipments: [Equipment] = []
    private var prebookingDates: Set<Date> = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCalendar()
    }
    
    private func setupCalendar() {
        if #available(iOS 16.0, *) {
            // Remove the date picker
            preBookingDatePicker.removeFromSuperview()
            
            // Create and configure calendar view
            let calendarView = UICalendarView()
            calendarView.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview(calendarView)
            
            // Setup calendar constraints
            NSLayoutConstraint.activate([
                calendarView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
                calendarView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
                calendarView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
                calendarView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
                calendarView.heightAnchor.constraint(equalToConstant: 400)
            ])
            
            // Configure calendar
            let gregorianCalendar = Calendar(identifier: .gregorian)
            calendarView.calendar = gregorianCalendar
            calendarView.tintColor = UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1)
            
            // Setup selection behavior with default selection
            let dateSelection = UICalendarSelectionSingleDate(delegate: self)
            
            // Set today's date as the default selection
            let todayComponents = gregorianCalendar.dateComponents([.year, .month, .day], from: Date())
            dateSelection.selectedDate = todayComponents
            
            calendarView.selectionBehavior = dateSelection
            
            // Rest of the calendar configuration
            calendarView.fontDesign = .rounded
            calendarView.backgroundColor = .systemBackground
            calendarView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 24, right: 0)
            
            let dateRange = DateInterval(start: Date(), end: Date().addingTimeInterval(30*24*60*60))
            calendarView.availableDateRange = dateRange
            calendarView.visibleDateComponents = todayComponents
            
            calendarView.delegate = self
            self.calendarView = calendarView
        } else {
            // Fallback for older iOS versions
            preBookingDatePicker.minimumDate = Date()
            preBookingDatePicker.tintColor = .systemGreen
            preBookingDatePicker.backgroundColor = .clear
            preBookingDatePicker.preferredDatePickerStyle = .inline
            preBookingDatePicker.addTarget(self, action: #selector(dateSelected(_:)), for: .valueChanged)
        }
    }
    
    func configure(with equipments: [Equipment]?, dataController: DataController?, prebookingDates: [Date] = []) {
        self.availableEquipments = equipments ?? []
        self.dataController = dataController
        self.prebookingDates = Set(prebookingDates.map { Calendar.current.startOfDay(for: $0) })
        
        if #available(iOS 16.0, *), let calendarView = self.calendarView {
            // Maintain current selection or set to today if none
            if let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate,
               selection.selectedDate == nil {
                let todayComponents = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                selection.selectedDate = todayComponents
            }
            
            // Get visible date range and refresh decorations for all visible dates
            let dateInterval = calendarView.visibleDateComponents
            refreshCalendarDecorations(around: dateInterval)
        }
    }
    
    private func updateAvailableDates() {
        guard let equipment = availableEquipments.first else { return }
        
        if #available(iOS 16.0, *), let calendarView = self.calendarView {
            calendarView.delegate = self
        }
    }
    
    @objc private func dateSelected(_ sender: UIDatePicker) {
        guard let equipment = availableEquipments.first,
              let dataController = dataController else { return }
        
        let selectedDate = sender.date
        
        if equipment.isAvailable(on: selectedDate) {
            NotificationCenter.default.post(
                name: .equipmentAvailabilityChanged,
                object: nil,
                userInfo: ["equipment": equipment, "date": selectedDate]
            )
        }
    }
    
    @available(iOS 16.0, *)
    func refreshCalendarDecorations(around dateComponents: DateComponents? = nil) {
        guard let calendarView = self.calendarView else { return }
        
        let calendar = Calendar.current
        var componentsToRefresh = Set<DateComponents>()
        
        // Get the visible month's date range
        let visibleDate = dateComponents ?? calendarView.visibleDateComponents
        if let date = calendar.date(from: visibleDate),
           let range = calendar.range(of: .day, in: .month, for: date) {
            
            // Create components for each day in the visible month
            for day in range {
                var components = visibleDate
                components.day = day
                if let dayDate = calendar.date(from: components) {
                    let startOfDay = calendar.startOfDay(for: dayDate)
                    let dayComponents = calendar.dateComponents([.year, .month, .day], from: startOfDay)
                    componentsToRefresh.insert(dayComponents)
                }
            }
        }
        
        // Add prebooking dates
        componentsToRefresh.formUnion(prebookingDates.map { calendar.dateComponents([.year, .month, .day], from: $0) })
        
        // Add today's date
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: Date())
        componentsToRefresh.insert(todayComponents)
        
        // Add current selection if different
        if let selection = calendarView.selectionBehavior as? UICalendarSelectionSingleDate,
           let selectedDate = selection.selectedDate {
            componentsToRefresh.insert(selectedDate)
        }
        
        // Perform the refresh
        DispatchQueue.main.async {
            calendarView.reloadDecorations(forDateComponents: Array(componentsToRefresh), animated: true)
        }
    }
    
    // Update availability check for multiple equipment
    private func areAllEquipmentsAvailable(on date: Date) -> Bool {
        guard !availableEquipments.isEmpty else { return false }
        return availableEquipments.allSatisfy { equipment in
            let startOfDay = Calendar.current.startOfDay(for: date)
            return equipment.isAvailable(on: startOfDay)
        }
    }
}

// MARK: - UICalendarViewDelegate
@available(iOS 16.0, *)
extension preBookingCalanderCollectionViewCell: UICalendarViewDelegate {
    func calendarView(_ calendarView: UICalendarView, decorationFor dateComponents: DateComponents) -> UICalendarView.Decoration? {
        guard let date = Calendar.current.date(from: dateComponents) else { return nil }
        let startOfDay = Calendar.current.startOfDay(for: date)
        let today = Calendar.current.startOfDay(for: Date())
        
        if date < today { return nil }
        
        let hasPreBooking = prebookingDates.contains(startOfDay)
        let isEquipmentAvailable = areAllEquipmentsAvailable(on: date)
        
        if hasPreBooking && isEquipmentAvailable {
            return UICalendarView.Decoration.default(
                color: .systemPurple,
                size: .medium
            )
        }
        
        if hasPreBooking {
            return UICalendarView.Decoration.default(
                color: .systemBlue,
                size: .medium
            )
        }
        
        if isEquipmentAvailable {
            return UICalendarView.Decoration.default(
                color: UIColor(red: 0.298, green: 0.498, blue: 0.345, alpha: 1),
                size: .medium
            )
        }
        
        return nil
    }
    
    func calendarView(_ calendarView: UICalendarView, didChangeVisibleDateComponentsFrom previousDateComponents: DateComponents) {
        refreshCalendarDecorations(around: calendarView.visibleDateComponents)
    }
}

// MARK: - UICalendarSelectionSingleDateDelegate
@available(iOS 16.0, *)
extension preBookingCalanderCollectionViewCell: UICalendarSelectionSingleDateDelegate {
    func dateSelection(_ selection: UICalendarSelectionSingleDate, didSelectDate dateComponents: DateComponents?) {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents) else { return }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let hasPreBooking = prebookingDates.contains(startOfDay)
        let isEquipmentAvailable = areAllEquipmentsAvailable(on: date)
        
        // Allow selection if date is valid
        let today = Calendar.current.startOfDay(for: Date())
        if startOfDay >= today {
            selection.setSelected(dateComponents, animated: true)
        }
        
        if hasPreBooking {
            NotificationCenter.default.post(
                name: .prebookingDateSelected,
                object: nil,
                userInfo: ["date": date]
            )
        }
        
        NotificationCenter.default.post(
            name: .equipmentAvailabilityChanged,
            object: nil,
            userInfo: [
                "equipment": availableEquipments.first as Any,
                "date": date,
                "isAvailable": isEquipmentAvailable,
                "hasPreBooking": hasPreBooking
            ]
        )
        
        // Refresh decorations immediately after selection
        refreshCalendarDecorations()
    }
    
    // Add this method to handle selection validation
    func dateSelection(_ selection: UICalendarSelectionSingleDate, canSelectDate dateComponents: DateComponents?) -> Bool {
        guard let dateComponents = dateComponents,
              let date = Calendar.current.date(from: dateComponents) else { return false }
        
        let startOfDay = Calendar.current.startOfDay(for: date)
        let today = Calendar.current.startOfDay(for: Date())
        
        // Only allow selection of today and future dates
        return startOfDay >= today
    }
}

// Update the Notification.Name extension to only include equipmentAvailabilityChanged
extension Notification.Name {
    static let equipmentAvailabilityChanged = Notification.Name("equipmentAvailabilityChanged")
}
