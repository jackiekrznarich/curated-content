import SwiftUI

// MARK: - View Models
class ContentViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var userInterests: Set<String> = []
    @Published var currentFocusDepth: Int = 0 
    
    private let contentGenerator: ContentGenerator
    
    init() {
        if let apiKey = Environment.variable("content") {
            self.contentGenerator = ContentGenerator(apiKey: apiKey)
        } else {
            // Handle the missing environment variable case
            fatalError("Missing required environment variable: content")
        }
        
        // Load initial content
        loadInitialPosts()
    }
    
    func loadInitialPosts() {
        // Get user interests from preferences
        let interests = Array(UserPreferences.shared.interests)
        
        // If no interests set, use some default topics
        let topics = interests.isEmpty ?
            ["Technology", "Science", "History", "Nature", "Art"] :
            interests
        
        // Generate posts for these topics
        contentGenerator.generateMultiplePosts(topics: topics) { [weak self] generatedPosts in
            DispatchQueue.main.async {
                self?.posts = generatedPosts
            }
        }
    }
    
    private func getTopicsBasedOnInteractions() -> [String] {
            return Array(userInterests).prefix(3).map { $0 }
        }
        
        // Generate subposts when a post is expanded
        func generateSubposts(for post: Post) -> [Post] {
            // For immediate response, return placeholder posts
            let placeholderPosts = [
                Post(content: "Loading more details about \(post.topic)...",
                     subposts: [],
                     topic: post.topic,
                     tags: post.tags,
                     depth: post.depth + 1,
                     source: .aiGenerated,
                     publishDate: Date(),
                     relatedTopics: [])
            ]
            
            // Then asynchronously generate real content
            let expandedPrompt = "Explain more about: \(post.content)"
            
            return placeholderPosts
        }
    
    func updateUserInterests(based post: Post) {
        userInterests.insert(post.topic)
        // Add tags to interests as well
        post.tags.forEach { userInterests.insert($0) }
        
        // Save to UserPreferences
        UserPreferences.shared.updateInterests(userInterests)
    }
    
    func updateFocusDepth(_ depth: Int) {
        withAnimation {
            currentFocusDepth = depth
        }
    }
    
    func loadMoreContent() {
        // Generate additional posts based on user interests
        let topics = getTopicsBasedOnInteractions()
        
        contentGenerator.generateMultiplePosts(topics: topics) { [weak self] newPosts in
            DispatchQueue.main.async {
                self?.posts.append(contentsOf: newPosts)
            }
        }
    }
}
