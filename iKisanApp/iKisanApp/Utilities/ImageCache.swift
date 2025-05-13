import UIKit

class ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()
    
    private init() {
        // Set limits to prevent memory issues
        cache.countLimit = 100
    }
    
    func image(for urlString: String) -> UIImage? {
        return cache.object(forKey: urlString as NSString)
    }
    
    func save(image: UIImage, for urlString: String) {
        cache.setObject(image, forKey: urlString as NSString)
    }
    
    func loadImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        // Check if image exists in cache
        if let cachedImage = image(for: urlString) {
            completion(cachedImage)
            return
        }
        
        // Create URL
        guard let url = URL(string: urlString) else {
            print("Invalid URL: \(urlString)")
            completion(nil)
            return
        }
        
        // Create URL request for the image download
        var request = URLRequest(url: url)
        
        // Using the Supabase API Key for authentication
        // Use the same key that's used to initialize the client
        let apiKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InB4dXV1cGlxZWlweWVtbHV5ZXJzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDUzMDUzMzQsImV4cCI6MjA2MDg4MTMzNH0.zH4zUtWuYB1YTzwIMx_Js6EgnI-s-3AV6WP0qsKjzZ8"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // Download image
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self,
                  let data = data,
                  let image = UIImage(data: data) else {
                print("Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            // Save to cache and return
            self.save(image: image, for: urlString)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

// Extension for UIImageView to load images from URL
extension UIImageView {
    func loadImage(from urlString: String, placeholder: UIImage? = UIImage(named: "placeholder_image")) {
        // Show placeholder while loading
        self.image = placeholder
        
        // Load image from cache or download
        ImageCache.shared.loadImage(from: urlString) { [weak self] image in
            DispatchQueue.main.async {
                if let image = image {
                    self?.image = image
                }
            }
        }
    }
}
