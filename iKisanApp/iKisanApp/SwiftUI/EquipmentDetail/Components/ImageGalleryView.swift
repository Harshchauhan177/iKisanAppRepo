//
//  ImageGalleryView.swift
//  iKisanApp
//
//  Full-screen image gallery following Apple HIG
//

import SwiftUI

struct ImageGalleryView: View {
    
    @Environment(\.dismiss) var dismiss
    @State private var currentIndex: Int
    let images: [String]
    
    init(images: [String], initialIndex: Int = 0) {
        self.images = images
        _currentIndex = State(initialValue: initialIndex)
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background - Adaptive for light/dark mode
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                // Main Content
                VStack(spacing: 0) {
                    // Image Viewer - Takes most space
                    TabView(selection: $currentIndex) {
                        ForEach(Array(images.enumerated()), id: \.offset) { index, imageName in
                            ZoomableImageView(imageName: imageName)
                                .tag(index)
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    
                    // Bottom Thumbnail Scroll
                    if images.count > 1 {
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 10) {
                                    ForEach(Array(images.enumerated()), id: \.offset) { index, imageName in
                                        ThumbnailView(
                                            imageName: imageName,
                                            isSelected: index == currentIndex
                                        )
                                        .onTapGesture {
                                            let generator = UIImpactFeedbackGenerator(style: .light)
                                            generator.impactOccurred()
                                            withAnimation(.easeInOut(duration: 0.3)) {
                                                currentIndex = index
                                            }
                                        }
                                        .id(index)
                                    }
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 16)
                            }
                            .frame(height: 100)
                            .background(
                                Color(UIColor.secondarySystemBackground)
                                    .overlay(
                                        Color.primary.opacity(0.05)
                                    )
                            )
                            .onChange(of: currentIndex) { newValue in
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(newValue, anchor: .center)
                                }
                            }
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    // Image counter in toolbar
                    HStack(spacing: 4) {
                        Text("\(currentIndex + 1)")
                            .font(.system(size: 17, weight: .bold))
                        Text("of")
                            .font(.system(size: 15, weight: .regular))
                            .opacity(0.8)
                        Text("\(images.count)")
                            .font(.system(size: 17, weight: .bold))
                    }
                    .foregroundColor(.primary)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.secondary)
                            .symbolRenderingMode(.hierarchical)
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Zoomable Image View
struct ZoomableImageView: View {
    let imageName: String
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            AsyncImageView(imageName: imageName)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            let delta = value / lastScale
                            lastScale = value
                            scale = min(max(scale * delta, 1), 4)
                        }
                        .onEnded { _ in
                            lastScale = 1.0
                            if scale < 1 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    scale = 1
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if scale > 1 {
                                let maxOffsetX = (geometry.size.width * (scale - 1)) / 2
                                let maxOffsetY = (geometry.size.height * (scale - 1)) / 2
                                
                                let newOffsetX = lastOffset.width + value.translation.width
                                let newOffsetY = lastOffset.height + value.translation.height
                                
                                offset = CGSize(
                                    width: min(max(newOffsetX, -maxOffsetX), maxOffsetX),
                                    height: min(max(newOffsetY, -maxOffsetY), maxOffsetY)
                                )
                            }
                        }
                        .onEnded { _ in
                            if scale > 1 {
                                lastOffset = offset
                            } else {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    offset = .zero
                                    lastOffset = .zero
                                }
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                    
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        if scale > 1 {
                            scale = 1
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.5
                        }
                    }
                }
        }
        .background(Color(UIColor.systemBackground))
    }
}

// MARK: - Async Image View
struct AsyncImageView: View {
    let imageName: String
    
    var body: some View {
        if imageName.hasPrefix("http") {
            AsyncImage(url: URL(string: imageName)) { phase in
                switch phase {
                case .empty:
                    ZStack {
                        Color(UIColor.systemBackground)
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                            .scaleEffect(1.5)
                    }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                case .failure:
                    ZStack {
                        Color(UIColor.systemBackground)
                        VStack(spacing: 16) {
                            Image(systemName: "photo.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary.opacity(0.5))
                            Text("Unable to load image")
                                .foregroundColor(.secondary)
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                @unknown default:
                    Color(UIColor.systemBackground)
                }
            }
        } else {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ZStack {
                    Color(UIColor.systemBackground)
                    VStack(spacing: 16) {
                        Image(systemName: "photo.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.secondary.opacity(0.5))
                        Text("Image not found")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                    }
                }
            }
        }
    }
}

// MARK: - Thumbnail View
struct ThumbnailView: View {
    let imageName: String
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            if imageName.hasPrefix("http") {
                AsyncImage(url: URL(string: imageName)) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color(UIColor.tertiarySystemFill))
                            .overlay(
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .secondary))
                                    .scaleEffect(0.8)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    case .failure:
                        Rectangle()
                            .fill(Color(UIColor.tertiarySystemFill))
                            .overlay(
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.secondary)
                            )
                    @unknown default:
                        Rectangle()
                            .fill(Color(UIColor.tertiarySystemFill))
                    }
                }
            } else {
                if let uiImage = UIImage(named: imageName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } else {
                    Rectangle()
                        .fill(Color(UIColor.tertiarySystemFill))
                        .overlay(
                            Image(systemName: "photo.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.secondary)
                        )
                }
            }
        }
        .frame(width: 70, height: 70)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.3), lineWidth: isSelected ? 3 : 1)
        )
        .scaleEffect(isSelected ? 1.0 : 0.95)
        .shadow(color: Color.primary.opacity(isSelected ? 0.3 : 0.15), radius: isSelected ? 8 : 4, x: 0, y: 2)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Preview
#Preview {
    ImageGalleryView(
        images: [
            "Image 1",
            "Image 2",
            "Image 3"
        ],
        initialIndex: 0
    )
}
