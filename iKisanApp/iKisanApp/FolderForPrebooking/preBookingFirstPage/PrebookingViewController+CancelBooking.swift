// Extension to PrebookingViewController to handle prebooking cancellation
import UIKit

extension PrebookingViewController {
    
    // Implementation of the delegate method for handling cancel button taps
    func didTapCancelButton(for booking: Booking, equipment: Equipment) {
        // Create modern alert with clear messaging
        let alert = UIAlertController(
            title: "Cancel Prebooking",
            message: "Are you sure you want to cancel this prebooking for \(equipment.name)?",
            preferredStyle: .alert
        )
        
        // Style the alert actions
        alert.addAction(UIAlertAction(title: "No, Keep Booking", style: .cancel))
        alert.addAction(UIAlertAction(title: "Yes, Cancel", style: .destructive) { [weak self] _ in
            guard let self = self else { return }
            
            // Show loading indicator with modern styling
            let loadingAlert = UIAlertController(title: nil, message: "Cancelling booking...", preferredStyle: .alert)
            
            // Create and configure activity indicator
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = .medium
            loadingIndicator.startAnimating()
            
            // Center the activity indicator in the alert
            let container = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            container.addSubview(loadingIndicator)
            loadingIndicator.center = container.center
            loadingAlert.view.addSubview(container)
            container.center = CGPoint(x: loadingAlert.view.bounds.midX, y: loadingAlert.view.bounds.midY - 10)
            
            self.present(loadingAlert, animated: true)
            
            // Cancel the booking in the database
            Task {
                var deletionSuccessful = false
                var errorMessage = "An unknown error occurred while canceling your booking."
                
                do {
                    // Delete the booking record completely
                    let response = try await SupabaseManager.shared.client
                        .from("bookings")
                        .delete()
                        .eq("bookingID", value: booking.bookingID.uuidString)
                        .execute()
                    
                    // Check if the deletion was successful by verifying the response
                    let data = response.data
                    if let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
                       !jsonArray.isEmpty {
                        // If we got a non-empty response, the deletion was successful
                        deletionSuccessful = true
                        print("Booking deletion successful with response: \(jsonArray)")
                    } else {
                        // Empty response might indicate no records were found/deleted
                        errorMessage = "Could not find the booking to cancel. It may have already been removed."
                        print("Booking deletion returned empty response - no records found/deleted")
                    }
                } catch {
                    errorMessage = "Error: \(error.localizedDescription)"
                    print("Error during booking deletion API call: \(error)")
                }
                
                // Show appropriate message based on actual deletion result
                await MainActor.run {
                    // Dismiss loading alert
                    loadingAlert.dismiss(animated: true) {
                        if deletionSuccessful {
                            // Add success haptic feedback
                            let successGenerator = UINotificationFeedbackGenerator()
                            successGenerator.notificationOccurred(.success)
                            
                            // Show success message with clear action
                            let successAlert = UIAlertController(
                                title: "Prebooking Cancelled",
                                message: "Your prebooking has been successfully cancelled.",
                                preferredStyle: .alert
                            )
                            successAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                                // Refresh the prebookings list
                                self.refreshPreBookings()
                                
                                // Post notification to refresh all booking lists in the app
                                NotificationCenter.default.post(name: NSNotification.Name("RefreshBookingsList"), object: nil)
                            })
                            self.present(successAlert, animated: true)
                        } else {
                            // Add error haptic feedback
                            let errorGenerator = UINotificationFeedbackGenerator()
                            errorGenerator.notificationOccurred(.error)
                            
                            // Show error message
                            let errorAlert = UIAlertController(
                                title: "Cancellation Failed",
                                message: errorMessage,
                                preferredStyle: .alert
                            )
                            errorAlert.addAction(UIAlertAction(title: "Try Again", style: .default) { _ in
                                // Refresh the prebookings list to show current state
                                self.refreshPreBookings()
                            })
                            errorAlert.addAction(UIAlertAction(title: "Contact Support", style: .default))
                            self.present(errorAlert, animated: true)
                        }
                    }
                }
            }
        })
        
        present(alert, animated: true)
    }
}
