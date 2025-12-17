//
//  AsyncCropImageView.swift
//  iKisanApp
//
//  Created by Senior iOS Engineer on 16/12/25.
//

import SwiftUI

/// Async image loader with caching for crop images
/// Handles loading states and provides fallback images
struct AsyncCropImageView: View {
    
    let url: String
    let placeholder: Image
    
    @State private var uiImage: UIImage?
    @State private var isLoading: Bool = true
    
    init(url: String, placeholder: Image = Image(systemName: "leaf")) {
        self.url = url
        self.placeholder = placeholder
    }
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
            } else if isLoading {
                ProgressView()
            } else {
                placeholder
                    .resizable()
                    .scaledToFit()
            }
        }
        .task {
            await loadImage()
        }
    }
    
    @MainActor
    private func loadImage() async {
        // Check cache first
        if let cachedImage = ImageCache.shared.image(for: url) {
            uiImage = cachedImage
            isLoading = false
            return
        }
        
        // Download image
        guard let imageUrl = URL(string: url) else {
            isLoading = false
            return
        }
        
        do {
            // Create URL request with Supabase authentication
            var request = URLRequest(url: imageUrl)
            let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4dXV1cGlxZWlweWVtbHV5ZXJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMDUzMzQsImV4cCI6MjA2MDg4MTMzNH0.zH4zUtWuYB1YTzwIMx_Js6EgnI-s-3AV6WP0qsKjzZ8"
            request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            
            let (data, _) = try await URLSession.shared.data(for: request)
            if let image = UIImage(data: data) {
                ImageCache.shared.save(image: image, for: url)
                uiImage = image
            }
        } catch {
            print("Error loading image: \(error)")
        }
        
        isLoading = false
    }
}
