import SwiftUI

struct PostView: View {
    @Binding var post: Post
    @ObservedObject var viewModel: ContentViewModel
    
    func backgroundColor(for depth: Int) -> Color {
        // Base blue values
        let baseRed: Double = 0.0
        let baseGreen: Double = 0.2
        let baseBlue: Double = 0.5
        
        // As depth increases, slightly adjust the color
        let adjustment: Double = min(Double(depth) * 0.07, 0.3)
        
        return Color(
            red: baseRed + (adjustment * 0.3),    // Very slight red increase
            green: baseGreen + (adjustment * 0.4), // Some green adjustment
            blue: baseBlue + adjustment            // More blue for deeper levels
        )
    }
    
    // Calculate opacity based on distance from current focused level
   func opacityForPost(currentFocusDepth: Int, postDepth: Int) -> Double {
       let distance = abs(currentFocusDepth - postDepth)
       
       // Posts at current focus depth have full opacity
       if distance == 0 {
           return 1.0
       }
       
       // Posts further away become increasingly transparent
       return max(1.0 - (Double(distance) * 0.25), 0.4)
   }
    // Calculate blur amount based on distance from current focused level
    func blurForPost(currentFocusDepth: Int, postDepth: Int) -> Double {
        let distance = abs(currentFocusDepth - postDepth)
        
        // No blur for current focus depth
        if distance == 0 {
            return 0.0
        }
        
        // Increase blur with distance
        return min(Double(distance) * 0.5, 10.0)
    }
    func resetDescendantExpansionState(for post: Post) {
        // Mark all subposts as not expanded
        for i in 0..<post.subposts.count {
            self.post.subposts[i].isExpanded = false
            
            // Recursively reset deeper levels
            if !post.subposts[i].subposts.isEmpty {
                resetDescendantExpansionState(for: post.subposts[i])
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 1) {
            // Main post content
            Button(action: {
                withAnimation {
                    post.isExpanded.toggle()
                    if post.isExpanded && post.subposts.isEmpty {
                        post.subposts = viewModel.generateSubposts(for: post)
                    }
                    post.interactionCount += 1
                    viewModel.updateUserInterests(based: post)
                    
                    // Update current focus depth when expanding a post
                    if post.isExpanded {
                        viewModel.updateFocusDepth(post.depth + 1)  // Focus on the level of subposts
                    } else {
                        viewModel.updateFocusDepth(post.depth)  // Focus back on this post's level
                        // Reset expansion state only for this post's descendants
                        resetDescendantExpansionState(for: post)
                    }
                }
            }) {
                Text(post.content)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(backgroundColor(for: post.depth))
                .cornerRadius(8)
                .opacity(opacityForPost(currentFocusDepth: viewModel.currentFocusDepth, postDepth: post.depth))
                .blur(radius: blurForPost(currentFocusDepth: viewModel.currentFocusDepth, postDepth: post.depth))

            }
            
            // Subposts
            if post.isExpanded {
                VStack(spacing: 1) {
                    ForEach($post.subposts) { $subpost in
                        PostView(post: $subpost, viewModel: viewModel)
                    }
                }
            }
        }
    }
}

#Preview {
    // A sample configuration of PostView for preview purposes
    PostView(post: .constant(Post(
        content: "Example post content",
        subposts: [],
        topic: "Sample",
        tags: ["preview"],
        depth: 0,
        source: .testing,
        relatedTopics: []
    )), viewModel: ContentViewModel(postsPerPage: 1))
}
