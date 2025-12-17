//
//  OnboardingViewModel.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 16/12/25.
//

import SwiftUI
import Combine

/// ViewModel for Onboarding screen following MVVM architecture
/// Handles all business logic and state management for the onboarding flow
@MainActor
final class OnboardingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var slides: [OnboardingSlideModel] = []
    @Published var currentPage: Int = 0
    @Published private(set) var buttonTitle: String = "Next"
    
    // MARK: - Private Properties
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    init() {
        setupSlides()
        observeCurrentPage()
    }
    
    // MARK: - Public Methods
    
    /// Advances to the next slide or completes onboarding if on the last slide
    func nextButtonTapped() {
        if currentPage == slides.count - 1 {
            completeOnboarding()
        } else {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentPage += 1
            }
        }
    }
    
    /// Skips the onboarding flow and completes it immediately
    func skipButtonTapped() {
        completeOnboarding()
    }
    
    /// Updates the current page when user swipes
    func updateCurrentPage(to page: Int) {
        currentPage = page
    }
    
    // MARK: - Private Methods
    
    private func setupSlides() {
        slides = [
            OnboardingSlideModel(
                title: "Find Equipments",
                description: "Find the best Equipments as service nearby your locality.",
                imageName: "on1",
                logoSystemName: "magnifyingglass"
            ),
            OnboardingSlideModel(
                title: "Co-Equip",
                description: "Team up with other users who need the same equipment for shared services.",
                imageName: "on2",
                logoSystemName: "person.3.fill"
            ),
            OnboardingSlideModel(
                title: "AgriAssist",
                description: "Find the best equipment for your agricultural needs.",
                imageName: "on3",
                logoSystemName: "lightbulb.max.fill"
            )
        ]
    }
    
    private func observeCurrentPage() {
        $currentPage
            .sink { [weak self] page in
                guard let self = self else { return }
                self.updateButtonTitle(for: page)
            }
            .store(in: &cancellables)
    }
    
    private func updateButtonTitle(for page: Int) {
        buttonTitle = page == slides.count - 1 ? "Get Started" : "Next"
    }
    
    private func completeOnboarding() {
        // Mark onboarding as completed
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // Notify that onboarding is complete
        NotificationCenter.default.post(name: .onboardingCompleted, object: nil)
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let onboardingCompleted = Notification.Name("onboardingCompleted")
}
