import SwiftUI
// MARK: - View Models
class ContentViewModel: ObservableObject {
    @Published var posts: [Post] = []
    @Published var userInterests: Set<String> = []
    @Published var currentFocusDepth: Int = 0
    
    init() {
        posts = [
            Post(content: "Welcome to Infinite Posts! Tap to learn more.",
                 subposts: [],
                 topic: "Welcome",
                 tags: ["introduction"],
                 depth: 0,
                 source: .testing,
                 relatedTopics: []),
            Post(content: "Did you know? The human brain processes images in just 13 milliseconds.",
                 subposts: [],
                 topic: "Science",
                 tags: ["brain", "psychology"],
                 depth: 0,
                 source: .testing,
                 relatedTopics: []),
            Post(content: "The first computer programmer was Ada Lovelace, who wrote algorithms for a mechanical computer in the 1840s.",
                 subposts: [],
                 topic: "Technology",
                 tags: ["history", "programming"],
                 depth: 0,
                 source: .testing,
                 relatedTopics: [])
        ]
    }
    
    func loadInitialPosts() {
        // TODO
    }
    
    func generateSubposts(for post: Post) -> [Post] {
        // Sample subpost generation
        return [
            Post(content: "Here's an interesting detail about \(post.topic)...",
                 subposts: [],
                 topic: post.topic,
                 tags: post.tags,
                 depth: post.depth + 1,
                 source: .testing,
                 relatedTopics: []),
            Post(content: "Another fascinating aspect of \(post.topic)...",
                 subposts: [],
                 topic: post.topic,
                 tags: post.tags,
                 depth: post.depth + 1,
                 source: .testing,
                 relatedTopics: []),
        ]
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
        // Generate a few more posts when the user scrolls to the bottom
        let newPosts = (0..<3).map { _ in
            let randomTopics = ["Technology", "Science", "Art", "History", "Nature"]
            let randomTopic = randomTopics.randomElement() ?? "General"
            return PostGenerator.generatePost(topic: randomTopic)
        }
        posts.append(contentsOf: newPosts)
    }
}
