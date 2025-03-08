import Foundation
// MARK: - Models
struct Post: Identifiable {
    let id = UUID()
    let content: String
    var subposts: [Post]
    var isExpanded: Bool = false
    var interactionCount: Int = 0
    var topic: String
    var tags: [String]
    let depth: Int
    
    // New fields
    var source: ContentSource
    var publishDate: Date?
    var expiryDate: Date?  // For time-sensitive content
    var confidenceScore: Float?  // For AI-generated content
    var externalLinks: [Link]?  // For references/citations
    var relatedTopics: [String]
}

enum ContentSource {
    case aiGenerated
    case news(source: String)
    case twitter(username: String)
    case wikipedia
    case userContributed
}

struct Link {
    let title: String
    let url: URL
    let type: LinkType
}

enum LinkType {
    case source
    case relatedArticle
    case deepDive
    case originalTweet
}
