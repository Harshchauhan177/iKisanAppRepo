//
//  CoEquipView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 25/12/25.
//

import SwiftUI

/// Custom segmented picker matching the screenshot's pill design
struct SegmentedPickerView: View {
    @Binding var selection: CoEquipViewModel.CoEquipTab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(CoEquipViewModel.CoEquipTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selection = tab
                    }
                } label: {
                    Text(tab.rawValue)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(selection == tab ? .primary : .secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            Group {
                                if selection == tab {
                                    Capsule()
                                        .fill(Color.white)
                                        .matchedGeometryEffect(id: "tab", in: animation)
                                        .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                                }
                            }
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(
            Capsule()
                .fill(Color(.systemGray5))
        )
        .padding(.horizontal, 16)
    }
}

/// Main Co-Equip view displaying "My Requests" and "Join Requests"
struct CoEquipView: View {
    @ObservedObject var viewModel: CoEquipViewModel
    @State private var showCreateRequest = false
    
    // iKisan brand green
    private let ikisanGreen = Color(red: 0.298, green: 0.498, blue: 0.345)
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color - standard iOS grouped background
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Segmented Picker
                    SegmentedPickerView(selection: $viewModel.selectedTab)
                        .padding(.top, 12)
                        .padding(.bottom, 16)
                    
                    // Content
                    if viewModel.isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.2)
                        Spacer()
                    } else if viewModel.currentRequests.isEmpty {
                        emptyStateView
                    } else {
                        requestsList
                    }
                }
            }
            .navigationTitle("Co-Equip")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink(isActive: $showCreateRequest) {
                        // Equipment selection is the first step in create request flow
                        SelectEquipmentView(
                            viewModel: SelectEquipmentViewModel(
                                dataController: viewModel.dataController,
                                initialSearchSuggestion: nil
                            )
                        )
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(ikisanGreen)
                    }
                    .accessibilityLabel("Create new request")
                }
            }
            .sheet(isPresented: $viewModel.showJoinInputSheet) {
                if let request = viewModel.selectedRequestForJoin {
                    JoinRequestInputView(
                        viewModel: JoinRequestInputViewModel(
                            request: request,
                            dataController: viewModel.dataController,
                            onJoinSuccess: { fieldArea in
                                Task {
                                    await viewModel.confirmJoin(request: request, fieldArea: fieldArea)
                                }
                            }
                        )
                    )
                }
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil), presenting: viewModel.errorMessage) { message in
                Button("OK") {
                    viewModel.errorMessage = nil
                }
            } message: { message in
                Text(message)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// List of request cards with native scrolling
    private var requestsList: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(viewModel.currentRequests) { request in
                    if viewModel.selectedTab == .joinRequests {
                        // Show Join Request card with Accept/Reject buttons
                        // Wrap in NavigationLink for navigation
                        NavigationLink(destination: destinationView(for: request)) {
                            CoEquipJoinRequestCard(
                                request: request,
                                creatorName: request.creatorName ?? "Unknown",
                                onAccept: {
                                    viewModel.acceptRequest(request)
                                },
                                onReject: {
                                    viewModel.rejectRequest(request)
                                }
                            )
                        }
                        .buttonStyle(.plain)
                    } else {
                        // Show My Request card with status badge
                        NavigationLink(destination: destinationView(for: request)) {
                            CoEquipRequestCard(request: request)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
    }
    
    /// Empty state when no requests are available
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Spacer()
            
            Image(systemName: "tray")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            Text("No Requests Yet")
                .font(.title2.bold())
                .foregroundColor(.primary)
            
            Text(viewModel.selectedTab == .myRequests
                 ? "Create a request to share equipment costs"
                 : "Join a request to collaborate with other farmers")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button {
                showCreateRequest = true
            } label: {
                Text("Create Request")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(ikisanGreen)
                    .clipShape(Capsule())
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    // MARK: - Actions
    
    /// Create destination view for navigation
    @ViewBuilder
    private func destinationView(for request: CoEquipRequest) -> some View {
        if let underlyingRequest = request.underlyingRequest {
            // Navigate to SwiftUI RequestDetailView
            RequestDetailView(
                viewModel: RequestDetailViewModel(
                    request: underlyingRequest,
                    dataController: viewModel.dataController,
                    coordinator: nil
                )
            )
        } else {
            // Fallback if no underlying request
            Text("Request details unavailable")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview("Co-Equip View") {
    CoEquipView(viewModel: CoEquipViewModel())
}

#Preview("Empty State") {
    struct EmptyPreview: View {
        @StateObject private var viewModel = CoEquipViewModel()
        
        var body: some View {
            NavigationStack {
                CoEquipView(viewModel: viewModel)
            }
            .onAppear {
                viewModel.myRequests = []
                viewModel.joinRequests = []
            }
        }
    }
    
    return EmptyPreview()
}
