import Foundation

class ContentGenerator {
    // API configuration
    private let apiKey: String
    private let baseURL: String
    
    // Initialize with your API credentials
    init(apiKey: String, baseURL: String = "https://api.openai.com/v1/chat/completions") {
        self.apiKey = apiKey
        self.baseURL = baseURL
    }
    
    // Generate a concise top-level post on a specific topic
    func generateTopLevelPost(topic: String, tags: [String] = [], completion: @escaping (Result<Post, Error>) -> Void) {
        // Create a prompt that will yield short, engaging content
        let prompt = createPrompt(topic: topic, tags: tags)
        
        // Set up the API request
        let requestBody = APIRequest(
            model: "gpt-3.5-turbo",
            messages: [
                Message(role: "system", content: "You are a concise knowledge assistant. Provide interesting facts in 1-3 sentences."),
                Message(role: "user", content: prompt)
            ],
            temperature: 0.7,
            max_tokens: 100
        )
        
        // Convert request to JSON data
        guard let jsonData = try? JSONEncoder().encode(requestBody) else {
            completion(.failure(ContentError.encodingFailed))
            return
        }
        
        // Create URLRequest
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        // Execute API call
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle network error
            if let error = error {
                completion(.failure(error))
                return
            }
            
            // Ensure we have data
            guard let data = data else {
                completion(.failure(ContentError.noData))
                return
            }
            
            // Parse response
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                
                if let generatedContent = apiResponse.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) {
                    // Create a new post with the generated content
                    let post = Post(
                        content: generatedContent,
                        subposts: [],
                        topic: topic,
                        tags: tags,
                        depth: 0,
                        source: .aiGenerated,
                        publishDate: Date(),
                        confidenceScore: 0.9,
                        relatedTopics: []
                    )
                    
                    completion(.success(post))
                } else {
                    completion(.failure(ContentError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }
        
        task.resume()
    }
    
    // Create optimized prompts for different content types
    private func createPrompt(topic: String, tags: [String]) -> String {
        let tagString = tags.isEmpty ? "" : " focusing on aspects related to: \(tags.joined(separator: ", "))"
        
        return """
        Share an interesting fact or insight about "\(topic)"\(tagString). 
        Keep it concise (1-3 sentences), engaging, and suitable for a general audience.
        Focus on providing uncommon knowledge that would make someone say "I didn't know that!"
        Don't use introductory phrases like "Did you know" or concluding remarks.
        """
    }
    
    // Support for batch generation
    func generateMultiplePosts(topics: [String], completion: @escaping ([Post]) -> Void) {
        var generatedPosts: [Post] = []
        let group = DispatchGroup()
        
        for topic in topics {
            group.enter()
            generateTopLevelPost(topic: topic) { result in
                if case .success(let post) = result {
                    generatedPosts.append(post)
                }
                group.leave()
            }
        }
        
        group.notify(queue: DispatchQueue.main) {
            completion(generatedPosts)
        }
    }
    
    // Error types
    enum ContentError: Error {
        case encodingFailed
        case noData
        case invalidResponse
    }
}

// API Models
struct APIRequest: Codable {
    let model: String
    let messages: [Message]
    let temperature: Float
    let max_tokens: Int
}

struct Message: Codable {
    let role: String
    let content: String
}

struct APIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}
