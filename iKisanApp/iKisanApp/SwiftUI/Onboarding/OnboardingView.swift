//
//  OnboardingView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 16/12/25.
//

import SwiftUI

/// SwiftUI view for the onboarding experience
/// Fully compliant with HIG, supports Dynamic Type, Dark Mode, and VoiceOver
struct OnboardingView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel = OnboardingViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            // Background
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Skip Button (hidden on last slide)
                if viewModel.currentPage < viewModel.slides.count - 1 {
                    skipButton
                        .padding(.top, 16)
                        .padding(.trailing, 20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                } else {
                    // Empty spacer for consistent layout
                    HStack {
                        Spacer()
                    }
                    .frame(height: 50)
                    .padding(.top, 16)
                }
                
                // Slides
                slidesContent
                    .padding(.top, 20)
                
                Spacer()
                    .frame(minHeight: 40)
                
                // Page Control
                pageControl
                    .padding(.bottom, 24)
                
                // Next/Get Started Button
                actionButton
                    .padding(.horizontal, 36)
                    .padding(.bottom, 44)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
    }
    
    // MARK: - View Components
    
    private var skipButton: some View {
        HStack {
            Spacer()
            Button(action: viewModel.skipButtonTapped) {
                Text("Skip")
                    .font(.system(size: 17, weight: .regular))
                    .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
            }
            .accessibilityLabel("Skip onboarding")
            .accessibilityHint("Skips the introduction and goes directly to the main app")
        }
    }
    
    private var slidesContent: some View {
        TabView(selection: $viewModel.currentPage) {
            ForEach(Array(viewModel.slides.enumerated()), id: \.element.id) { index, slide in
                OnboardingSlideView(slide: slide)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.3), value: viewModel.currentPage)
        .frame(maxHeight: .infinity)
    }
    
    private var pageControl: some View {
        HStack(spacing: 10) {
            ForEach(0..<viewModel.slides.count, id: \.self) { index in
                Circle()
                    .fill(index == viewModel.currentPage ? 
                          Color(red: 0.298, green: 0.498, blue: 0.345) : 
                          Color.gray.opacity(0.3))
                    .frame(width: index == viewModel.currentPage ? 10 : 8, 
                           height: index == viewModel.currentPage ? 10 : 8)
                    .animation(.easeInOut(duration: 0.2), value: viewModel.currentPage)
                    .accessibilityHidden(true)
            }
        }
    }
    
    private var actionButton: some View {
        Button(action: viewModel.nextButtonTapped) {
            Text(viewModel.buttonTitle)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(red: 0.298, green: 0.498, blue: 0.345))
                )
                .shadow(color: Color(red: 0.298, green: 0.498, blue: 0.345).opacity(0.3), 
                       radius: 8, x: 0, y: 4)
        }
        .accessibilityLabel(viewModel.buttonTitle)
        .accessibilityHint(viewModel.currentPage == viewModel.slides.count - 1 ? 
                          "Complete onboarding and continue to app" : 
                          "Go to next slide")
    }
}

// MARK: - Onboarding Slide View

/// Individual slide view with image, logo, title, and description
private struct OnboardingSlideView: View {
    
    let slide: OnboardingSlideModel
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 20)
            
            // Main Image with fixed dimensions
            if let image = UIImage(named: slide.imageName) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 320, height: 330)
                    .accessibilityHidden(true)
            }
            
            Spacer()
                .frame(height: 48)
            
            // Logo and Title Section
            HStack(alignment: .center, spacing: 12) {
                // Logo icon with background circle
                ZStack {
                    Circle()
                        .fill(Color(red: 0.298, green: 0.498, blue: 0.345).opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: slide.logoSystemName)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(Color(red: 0.298, green: 0.498, blue: 0.345))
                }
                .accessibilityHidden(true)
                
                Text(slide.title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .padding(.horizontal, 32)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // Description
            Text(slide.description)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.leading)
                .lineSpacing(6)
                .padding(.horizontal, 32)
                .padding(.top, 16)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(slide.title). \(slide.description)")
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    OnboardingView()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    OnboardingView()
        .preferredColorScheme(.dark)
}

#Preview("Large Text") {
    OnboardingView()
        .environment(\.sizeCategory, .accessibilityExtraExtraExtraLarge)
}
