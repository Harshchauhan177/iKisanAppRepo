//
//  RealtimeManager.swift
//  iKisanApp
//
//  Created for real-time WebSocket subscriptions to Supabase.
//  Replaces manual pull-to-refresh with instant updates.
//
//  Compatible with supabase-swift v2.26.1
//

import Foundation
import Supabase
import Realtime

// MARK: - RealtimeManager
/// Manages real-time WebSocket subscriptions to Supabase tables.
/// Provides instant UI updates when providers accept/cancel requests.
@MainActor
final class RealtimeManager: ObservableObject {
    static let shared = RealtimeManager()

    // MARK: - Published Properties
    @Published private(set) var isConnected: Bool = false
    @Published private(set) var lastRequestUpdate: Date?
    @Published private(set) var lastBookingUpdate: Date?
    @Published private(set) var connectionError: String?

    // MARK: - Private Properties
    private var requestsChannel: RealtimeChannelV2?
    private var bookingsChannel: RealtimeChannelV2?
    private var currentUserId: UUID?
    private var isSubscribing: Bool = false

    // Tasks for listening to changes
    private var requestsListenerTask: Task<Void, Never>?
    private var bookingsListenerTask: Task<Void, Never>?

    private init() {
        print("🔌 [Realtime] RealtimeManager initialized")
    }

    // MARK: - Public Methods

    /// Subscribe to real-time updates for a specific user's requests and bookings.
    /// Call this when the user logs in or when the app becomes active.
    /// - Parameter userId: The farmer's UUID to listen for updates
    func subscribeToUserUpdates(userId: UUID) async {
        guard !isSubscribing else {
            print("⚠️ [Realtime] Already subscribing, skipping duplicate call")
            return
        }

        isSubscribing = true
        currentUserId = userId
        connectionError = nil

        print("🔌 [Realtime] Setting up subscriptions for user: \(userId)")

        // Subscribe to both tables
        await subscribeToRequestUpdates(userId: userId)
        await subscribeToBookingUpdates(userId: userId)

        isConnected = (requestsChannel != nil || bookingsChannel != nil)
        isSubscribing = false

        if isConnected {
            print("✅ [Realtime] Subscriptions active for user: \(userId)")
        } else {
            print("⚠️ [Realtime] No active subscriptions for user: \(userId)")
        }
    }

    /// Subscribe to UPDATE events on the 'requests' table for CoEquip requests.
    /// Triggers when provider accepts/cancels a request.
    /// - Parameter userId: The farmer's UUID
    func subscribeToRequestUpdates(userId: UUID) async {
        // Cancel existing listener task
        requestsListenerTask?.cancel()
        requestsListenerTask = nil

        // Unsubscribe from existing channel if any
        if let existingChannel = requestsChannel {
            await existingChannel.unsubscribe()
            requestsChannel = nil
        }

        let channelId = "requests-\(userId.uuidString.prefix(8))-\(Int(Date().timeIntervalSince1970))"

        print("📡 [Realtime] Subscribing to requests table for user: \(userId)")
        print("📡 [Realtime] Channel ID: \(channelId)")

        do {
            // Create a channel for the requests table
            let channel = SupabaseManager.shared.client.realtimeV2.channel(channelId)

            // Set up postgres change listener for UPDATE events
            // Filter by userId column matching the farmer's ID
            let changes = channel.postgresChange(
                UpdateAction.self,
                schema: "public",
                table: "requests",
                filter: "userId=eq.\(userId.uuidString)"
            )

            // Subscribe to the channel
            await channel.subscribe()

            // Verify subscription status
            let status = await channel.status
            print("📡 [Realtime] Requests channel status: \(status)")

            requestsChannel = channel

            // Start listening for changes in a background task
            requestsListenerTask = Task { [weak self] in
                print("👂 [Realtime] Listening for request changes...")
                for await change in changes {
                    guard !Task.isCancelled else { break }
                    await self?.handleRequestUpdate(change)
                }
                print("👂 [Realtime] Stopped listening for request changes")
            }

            print("✅ [Realtime] Subscribed to requests channel: \(channelId)")

        } catch {
            print("❌ [Realtime] Error subscribing to requests: \(error)")
            connectionError = "Failed to subscribe to requests: \(error.localizedDescription)"
        }
    }

    /// Subscribe to UPDATE events on the 'bookings' table for individual requests.
    /// Triggers when provider confirms/cancels a booking.
    /// - Parameter userId: The farmer's UUID
    func subscribeToBookingUpdates(userId: UUID) async {
        // Cancel existing listener task
        bookingsListenerTask?.cancel()
        bookingsListenerTask = nil

        // Unsubscribe from existing channel if any
        if let existingChannel = bookingsChannel {
            await existingChannel.unsubscribe()
            bookingsChannel = nil
        }

        let channelId = "bookings-\(userId.uuidString.prefix(8))-\(Int(Date().timeIntervalSince1970))"

        print("📡 [Realtime] Subscribing to bookings table for user: \(userId)")
        print("📡 [Realtime] Channel ID: \(channelId)")

        do {
            let channel = SupabaseManager.shared.client.realtimeV2.channel(channelId)

            // Note: The bookings table uses "userID" (capital ID) based on BookingDTO
            let changes = channel.postgresChange(
                UpdateAction.self,
                schema: "public",
                table: "bookings",
                filter: "userID=eq.\(userId.uuidString)"
            )

            await channel.subscribe()

            let status = await channel.status
            print("📡 [Realtime] Bookings channel status: \(status)")

            bookingsChannel = channel

            // Start listening for changes
            bookingsListenerTask = Task { [weak self] in
                print("👂 [Realtime] Listening for booking changes...")
                for await change in changes {
                    guard !Task.isCancelled else { break }
                    await self?.handleBookingUpdate(change)
                }
                print("👂 [Realtime] Stopped listening for booking changes")
            }

            print("✅ [Realtime] Subscribed to bookings channel: \(channelId)")

        } catch {
            print("❌ [Realtime] Error subscribing to bookings: \(error)")
            connectionError = "Failed to subscribe to bookings: \(error.localizedDescription)"
        }
    }

    /// Unsubscribe from all real-time channels.
    /// Call this when the user logs out or when the app goes to background.
    func unsubscribeAll() async {
        print("🔌 [Realtime] Unsubscribing from all channels...")

        // Cancel listener tasks first
        requestsListenerTask?.cancel()
        requestsListenerTask = nil
        bookingsListenerTask?.cancel()
        bookingsListenerTask = nil

        if let channel = requestsChannel {
            await channel.unsubscribe()
            requestsChannel = nil
            print("🔌 [Realtime] Unsubscribed from requests channel")
        }

        if let channel = bookingsChannel {
            await channel.unsubscribe()
            bookingsChannel = nil
            print("🔌 [Realtime] Unsubscribed from bookings channel")
        }

        currentUserId = nil
        isConnected = false
        connectionError = nil

        print("✅ [Realtime] All channels unsubscribed")
    }

    /// Reconnect to all channels (useful after network interruption)
    func reconnect() async {
        guard let userId = currentUserId else {
            print("⚠️ [Realtime] No user ID to reconnect for")
            return
        }

        print("🔄 [Realtime] Reconnecting...")
        await unsubscribeAll()

        // Small delay before reconnecting
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

        await subscribeToUserUpdates(userId: userId)
    }

    // MARK: - Private Methods

    /// Handle incoming UPDATE event from the requests table.
    private func handleRequestUpdate(_ change: UpdateAction) async {
        print("📥 [Realtime] Received request update")
        print("📥 [Realtime] Record: \(change.record)")

        // Extract status from the change payload
        if let statusValue = change.record["status"] {
            let status = extractStringValue(from: statusValue)
            print("📥 [Realtime] Request status changed to: \(status)")

            // Check if status is "Confirmed" or "cancelled" (case-insensitive)
            let normalizedStatus = status.lowercased()
            if normalizedStatus == "confirmed" || normalizedStatus == "cancelled" ||
               normalizedStatus == "completed" || normalizedStatus == "active" {
                await triggerRequestsUpdate()
            }
        } else {
            // If we can't determine status, trigger update anyway to be safe
            print("📥 [Realtime] Could not extract status, triggering update anyway")
            await triggerRequestsUpdate()
        }

        lastRequestUpdate = Date()
    }

    /// Handle incoming UPDATE event from the bookings table.
    private func handleBookingUpdate(_ change: UpdateAction) async {
        print("📥 [Realtime] Received booking update")
        print("📥 [Realtime] Record: \(change.record)")

        // Extract status from the change payload
        if let statusValue = change.record["status"] {
            let status = extractStringValue(from: statusValue)
            print("📥 [Realtime] Booking status changed to: \(status)")

            // Check if status indicates a significant change
            let normalizedStatus = status.lowercased()
            if normalizedStatus == "confirmed" || normalizedStatus == "cancelled" ||
               normalizedStatus == "completed" || normalizedStatus == "active" {
                await triggerBookingsUpdate()
            }
        } else {
            print("📥 [Realtime] Could not extract status, triggering update anyway")
            await triggerBookingsUpdate()
        }

        lastBookingUpdate = Date()
    }

    /// Extract string value from AnyJSON
    private func extractStringValue(from value: AnyJSON) -> String {
        switch value {
        case .string(let str):
            return str
        case .integer(let num):
            return String(num)
        case .double(let num):
            return String(num)
        case .bool(let bool):
            return String(bool)
        case .null:
            return ""
        case .object(_), .array(_):
            return ""
        }
    }

    /// Trigger UI updates when a request status changes.
    private func triggerRequestsUpdate() async {
        print("🔄 [Realtime] Triggering requests update...")

        // 1. Post NotificationCenter event for immediate UI response
        NotificationCenter.default.post(name: .requestsUpdated, object: nil)
        NotificationCenter.default.post(name: .realtimeRequestStatusChanged, object: nil)

        // 2. Fetch active service requests if we have a user ID
        if let userId = currentUserId {
            Task.detached {
                let _ = await RequestManager.shared.fetchActiveServiceRequests(for: userId)
            }
        }

        // 3. Post additional notification for active jobs tab
        NotificationCenter.default.post(name: .activeJobsUpdated, object: nil)

        print("✅ [Realtime] Requests update triggered")
    }

    /// Trigger UI updates when a booking status changes.
    private func triggerBookingsUpdate() async {
        print("🔄 [Realtime] Triggering bookings update...")

        // 1. Post NotificationCenter events
        NotificationCenter.default.post(name: .requestsUpdated, object: nil)
        NotificationCenter.default.post(name: .bookingAdded, object: nil)
        NotificationCenter.default.post(name: .realtimeBookingStatusChanged, object: nil)

        // 2. Fetch active service requests if we have a user ID
        if let userId = currentUserId {
            Task.detached {
                let _ = await RequestManager.shared.fetchActiveServiceRequests(for: userId)
            }
        }

        // 3. Post additional notification for active jobs
        NotificationCenter.default.post(name: .activeJobsUpdated, object: nil)

        print("✅ [Realtime] Bookings update triggered")
    }
}

// MARK: - Notification Names Extension
extension Notification.Name {
    /// Posted when a request status changes via Realtime (Confirmed/Cancelled)
    static let realtimeRequestStatusChanged = Notification.Name("realtimeRequestStatusChanged")

    /// Posted when a booking status changes via Realtime
    static let realtimeBookingStatusChanged = Notification.Name("realtimeBookingStatusChanged")
}

// MARK: - Usage Example
/*
 // In your App or SceneDelegate, after user login:
 Task {
     await RealtimeManager.shared.subscribeToUserUpdates(userId: currentUser.id)
 }

 // In your SwiftUI View:
 .onReceive(NotificationCenter.default.publisher(for: .requestsUpdated)) { _ in
     // Refresh your data
     Task {
         await viewModel.refreshRequests()
     }
 }

 // When user logs out:
 Task {
     await RealtimeManager.shared.unsubscribeAll()
 }

 // Handle app lifecycle:
 .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
     Task {
         await RealtimeManager.shared.reconnect()
     }
 }
*/
